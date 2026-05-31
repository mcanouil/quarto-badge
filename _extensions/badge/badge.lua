--- @module "badge"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil

--- Extension name constant
local EXTENSION_NAME = 'badge'

--- Load modules
local str = require(quarto.utils.resolve_path('_modules/string.lua'):gsub('%.lua$', ''))
local meta_mod = require(quarto.utils.resolve_path('_modules/metadata.lua'):gsub('%.lua$', ''))
local pdoc = require(quarto.utils.resolve_path('_modules/pandoc-helpers.lua'):gsub('%.lua$', ''))
local log = require(quarto.utils.resolve_path('_modules/logging.lua'):gsub('%.lua$', ''))
local colour_mod = require(quarto.utils.resolve_path('_modules/colour.lua'):gsub('%.lua$', ''))

--- Flag to track if deprecation warning has been shown.
--- @type boolean
local deprecation_warning_shown = false

--- Per-render cache of warned unknown badge keys.
--- Prevents repeated warnings for the same key in one document.
--- @type table<string, boolean>
local warned_unknown_keys = {}

--- Per-render cache of warned invalid colour values.
--- @type table<string, boolean>
local warned_invalid_colours = {}

--- Per-render cache of warned invalid URLs.
--- @type table<string, boolean>
local warned_invalid_urls = {}

--- Allowed link target values per the HTML specification.
--- @type table<string, boolean>
local ALLOWED_TARGETS = {
  ['_self'] = true,
  ['_blank'] = true,
  ['_parent'] = true,
  ['_top'] = true
}

--- Check whether a value looks like a syntactically plausible URL.
--- Accepts absolute URLs (`scheme://...`), root-relative (`/...`), hash (`#...`),
--- mailto/tel schemes, and relative paths. Rejects whitespace and obvious
--- control characters.
--- @param url string The URL to validate
--- @return boolean True when the URL is plausibly well-formed
local function is_plausible_url(url)
  if str.is_empty(url) then return false end
  if url:find('%s') then return false end
  if url:find('[%c]') then return false end
  if url:match('^https?://') then return true end
  if url:match('^mailto:') then return true end
  if url:match('^tel:') then return true end
  if url:match('^ftp://') then return true end
  if url:match('^/') then return true end
  if url:match('^#') then return true end
  if url:match('^%?') then return true end
  if url:match('^[%w%._/%-]+$') then return true end
  return false
end

--- Check whether a colour value is acceptable for CSS background-color.
--- Accepts CSS named colours, hex (3/4/6/8), and the functional rgb/rgba/hsl/hsla/hwb/lab/lch/oklab/oklch/color forms.
--- @param value string The colour to validate
--- @return boolean True when the colour is recognised
local function is_valid_colour(value)
  if str.is_empty(value) then return false end
  local lowered = value:lower():match('^%s*(.-)%s*$')
  if lowered == 'transparent' or lowered == 'currentcolor' or lowered == 'inherit' then
    return true
  end
  if colour_mod.is_named_colour(lowered) then return true end
  if lowered:match('^#%x%x%x%x?%x?%x?%x?%x?$') and (#lowered == 4 or #lowered == 5 or #lowered == 7 or #lowered == 9) then
    return true
  end
  if lowered:match('^rgba?%(.-%)$') then return true end
  if lowered:match('^hsla?%(.-%)$') then return true end
  if lowered:match('^hwb%(.-%)$') then return true end
  if lowered:match('^lab%(.-%)$') then return true end
  if lowered:match('^lch%(.-%)$') then return true end
  if lowered:match('^oklab%(.-%)$') then return true end
  if lowered:match('^oklch%(.-%)$') then return true end
  if lowered:match('^color%(.-%)$') then return true end
  return false
end

--- Load base badge configurations from document metadata, preferring the
--- scoped `extensions.badge` table and falling back to the deprecated
--- top-level `badge` key.
--- @param meta table Document metadata
--- @return table|nil Array of base badge configurations
local function load_base_badges(meta)
  local from_extension = meta_mod.get_extension_config(meta, EXTENSION_NAME)
  if from_extension then return from_extension end

  local from_deprecated
  from_deprecated, deprecation_warning_shown = meta_mod.check_deprecated_config(
    meta,
    EXTENSION_NAME,
    nil,
    deprecation_warning_shown
  )
  return from_deprecated
end

--- Merge document-level badge overrides into base configurations.
--- Overrides are matched by `key`; existing fields are replaced and new keys
--- are appended. Honoured override sources, in order of precedence:
---   1. `badge-overrides` (top-level).
---   2. `extensions.badge-overrides`.
--- @param base table|nil Array of base badge configurations
--- @param meta table Document metadata
--- @return table Array of effective badge configurations
local function apply_overrides(base, meta)
  local result = {}
  if base then
    for _, entry in ipairs(base) do
      table.insert(result, entry)
    end
  end

  local overrides = meta['badge-overrides']
  if not overrides and meta.extensions then
    overrides = meta.extensions['badge-overrides']
  end
  if not overrides then return result end

  for _, override in ipairs(overrides) do
    local override_key = str.stringify(override['key'])
    if not str.is_empty(override_key) then
      local replaced = false
      for index, entry in ipairs(result) do
        if str.stringify(entry['key']) == override_key then
          result[index] = override
          replaced = true
          break
        end
      end
      if not replaced then
        table.insert(result, override)
      end
    end
  end

  return result
end

--- Find the badge configuration matching the requested key.
--- @param badge_configs table Array of badge configurations
--- @param badge_key string Requested badge key
--- @return table|nil Matching configuration
local function find_badge_config(badge_configs, badge_key)
  for _, badge_config in ipairs(badge_configs) do
    if str.stringify(badge_config['key']) == badge_key then
      return badge_config
    end
  end
  return nil
end

--- Substitute the `{{value}}` placeholder in a URL template.
--- @param template string URL template
--- @param value string Raw badge value
--- @return string URL with the placeholder replaced
local function substitute_value(template, value)
  if not template:find('{{value}}', 1, true) then
    return template
  end
  --- Escape pattern replacement specials so % in the value is not treated
  --- as a back-reference by gsub.
  local replacement = value:gsub('%%', '%%%%')
  local replaced = template:gsub('{{value}}', replacement)
  return replaced
end

--- Build the HTML for the badge content, escaping all user-supplied values.
--- @param badge_config table Resolved badge configuration
--- @param badge_value string Raw badge value to display
--- @return string HTML markup for the badge
local function build_badge_html(badge_config, badge_value)
  --- @type string Optional CSS class list from configuration
  local css_class = ''
  if not str.is_empty(badge_config['class']) then
    css_class = str.stringify(badge_config['class'])
  end

  --- @type string Optional icon name (Bootstrap icons) prepended to value
  local icon_html = ''
  if not str.is_empty(badge_config['icon']) then
    local icon_name = str.stringify(badge_config['icon'])
    icon_html = '<i class="bi bi-' .. str.escape_attribute(icon_name) ..
      '" aria-hidden="true"></i> '
  end

  --- @type string Escaped badge value for safe HTML insertion
  local escaped_value = str.escape_html(badge_value)
  --- @type string Full inner HTML for the badge body
  local inner_html = icon_html .. escaped_value

  -- Optional href: wrap inner content in an anchor.
  if not str.is_empty(badge_config['href']) then
    local href_template = str.stringify(badge_config['href'])
    local resolved_href = substitute_value(href_template, badge_value)
    if not is_plausible_url(resolved_href) then
      if not warned_invalid_urls[resolved_href] then
        log.log_warning(
          EXTENSION_NAME,
          'Ignoring malformed href "' .. resolved_href ..
          '" for badge key "' .. str.stringify(badge_config['key']) .. '".'
        )
        warned_invalid_urls[resolved_href] = true
      end
    else
      local anchor_attrs = 'href="' .. str.escape_attribute(resolved_href) ..
        '" class="quarto-badge-href"'

      if not str.is_empty(badge_config['target']) then
        local target_value = str.stringify(badge_config['target'])
        if ALLOWED_TARGETS[target_value] then
          anchor_attrs = anchor_attrs ..
            ' target="' .. str.escape_attribute(target_value) .. '"'
          if target_value == '_blank' then
            anchor_attrs = anchor_attrs .. ' rel="noopener noreferrer"'
          end
        else
          log.log_warning(
            EXTENSION_NAME,
            'Ignoring unsupported target "' .. target_value ..
            '" for badge key "' .. str.stringify(badge_config['key']) ..
            '". Allowed: _self, _blank, _parent, _top.'
          )
        end
      end

      inner_html = '<a ' .. anchor_attrs .. '>' .. inner_html .. '</a>'
    end
  end

  -- Optional inline background-colour style.
  local style_attr = ''
  local colour_value = badge_config['colour'] or badge_config['color']
  if not str.is_empty(colour_value) then
    local colour_string = str.stringify(colour_value)
    if is_valid_colour(colour_string) then
      style_attr = 'style="background-color: ' ..
        str.escape_attribute(colour_string) .. ';" '
    else
      if not warned_invalid_colours[colour_string] then
        log.log_warning(
          EXTENSION_NAME,
          'Ignoring invalid colour "' .. colour_string ..
          '" for badge key "' .. str.stringify(badge_config['key']) ..
          '". Expected a CSS named colour, hex, rgb/rgba, hsl/hsla, or hwb value.'
        )
        warned_invalid_colours[colour_string] = true
      end
    end
  end

  -- Optional title tooltip.
  local title_attr = ''
  if not str.is_empty(badge_config['title']) then
    local title_value = str.stringify(badge_config['title'])
    local resolved_title = substitute_value(title_value, badge_value)
    title_attr = 'title="' .. str.escape_attribute(resolved_title) .. '" '
  end

  return '<span class="badge rounded-pill quarto-badge ' ..
    str.escape_attribute(css_class) .. '" ' ..
    style_attr ..
    title_attr ..
    '>' ..
    inner_html ..
    '</span>'
end

--- Badge shortcode handler.
--- Generates styled badge elements from document metadata configuration.
--- Badges are defined in document metadata with key, class, colour, icon,
--- href, target, and title properties.
---
--- @param args table Array of positional arguments (badge key and value)
--- @param _kwargs table Table of named keyword arguments (unused)
--- @param meta table Document metadata containing badge definitions
--- @return pandoc.RawInline HTML badge element, or an empty inline for non-HTML formats and warning paths
--- @usage {{< badge key value >}}
local function badge(args, _kwargs, meta)
  if not quarto.doc.is_format('html') then
    return pandoc.RawInline('html', '')
  end

  quarto.doc.add_html_dependency({
    name = EXTENSION_NAME,
    stylesheets = {'badge.css'}
  })

  --- @type string Requested badge key
  local badge_key = str.stringify(args[1])
  --- @type string Badge value to display
  local badge_value = str.stringify(args[2])

  if str.is_empty(badge_key) then
    log.log_warning(EXTENSION_NAME, 'Badge shortcode requires a key as the first argument.')
    return pandoc.RawInline('html', '')
  end

  local base_badges = load_base_badges(meta)
  local badge_configs = apply_overrides(base_badges, meta)

  if pdoc.is_object_empty(badge_configs) then
    log.log_warning(
      EXTENSION_NAME,
      'No badge configuration found. Define badges under "extensions.badge" in document or project metadata.'
    )
    return pandoc.RawInline('html', '')
  end

  local match = find_badge_config(badge_configs, badge_key)
  if match == nil then
    if not warned_unknown_keys[badge_key] then
      log.log_warning(
        EXTENSION_NAME,
        'No badge configuration matches key "' .. badge_key ..
        '". Add an entry with this key under "extensions.badge".'
      )
      warned_unknown_keys[badge_key] = true
    end
    return pandoc.RawInline('html', '')
  end

  return pandoc.RawInline('html', build_badge_html(match, badge_value))
end

--- Module export table.
--- Defines the shortcode available to Quarto for processing.
--- @type table<string, function>
return {
  ['badge'] = badge
}
