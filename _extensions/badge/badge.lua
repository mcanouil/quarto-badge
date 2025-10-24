--[[
# MIT License
#
# Copyright (c) 2025 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

--- Extension name constant
local EXTENSION_NAME = 'badge'

--- Load utils module
local utils = require(quarto.utils.resolve_path('_modules/utils.lua'):gsub('%.lua$', ''))

--- Flag to track if deprecation warning has been shown
--- @type boolean
local deprecation_warning_shown = false

--- Badge shortcode handler.
--- Generates styled badge elements from document metadata configuration.
--- Badges are defined in document metadata with key, class, colour, and href properties.
--- The shortcode renders badges with optional hyperlinks and custom styling.
---
--- @param args table Array of positional arguments (badge key and value)
--- @param _kwargs table Table of named keyword arguments (unused)
--- @param meta table Document metadata containing badge definitions
--- @return pandoc.RawInline|nil HTML badge element or nil for non-HTML formats
--- @usage {{< badge key value >}}
local function badge(args, _kwargs, meta)
  if not quarto.doc.is_format('html') then
    return nil
  end

  quarto.doc.add_html_dependency({
    name = EXTENSION_NAME,
    stylesheets = {'badge.css'}
  })

  --- @type string Badge key from metadata
  local badgeKey = utils.stringify(args[1])
  --- @type string Badge value/content to display
  local badgeValue = utils.stringify(args[2])

  -- Get badge configurations from metadata (prefer scoped extensions.badge)
  --- @type table|nil Array of badge configurations
  local badge_configs
  if meta['extensions'] ~= nil and meta['extensions'][EXTENSION_NAME] ~= nil then
    badge_configs = meta['extensions'][EXTENSION_NAME]
  else
    -- Check deprecated top-level structure
    badge_configs, deprecation_warning_shown = utils.check_deprecated_config(
      meta,
      EXTENSION_NAME,
      nil,  -- nil key indicates we want the entire extension config (array)
      deprecation_warning_shown
    )
  end

  if utils.is_object_empty(badge_configs) then
    return nil
  end

  --- @type string HTML content for the badge
  local badgeContent = ''

  for _, badge_config in ipairs(badge_configs) do
    --- @type string Badge key from metadata entry
    local metaBadgeKey = utils.stringify(badge_config['key'])

    if metaBadgeKey == badgeKey then
      --- @type string CSS class for the badge
      local metaBadgeClass = ''
      if not utils.is_empty(badge_config['class']) then
        metaBadgeClass = utils.stringify(badge_config['class'])
      end

      --- @type string Badge value (potentially wrapped in link)
      local displayValue = badgeValue

      -- Process optional href (hyperlink)
      if not utils.is_empty(badge_config['href']) then
        --- @type string Hyperlink URL for the badge
        local metaBadgeHref = utils.stringify(badge_config['href'])
        -- Replace {{value}} placeholder with actual badge value
        if metaBadgeHref:find('{{value}}') then
          metaBadgeHref = metaBadgeHref:gsub('{{value}}', badgeValue)
        end
        displayValue = '<a ' ..
          'href="' .. metaBadgeHref .. '" ' ..
          'class="quarto-badge-href"' ..
          '>' ..
          badgeValue ..
          '</a>'
      end

      -- Process optional colour/color
      --- @type string Custom style attribute for badge colour
      local style = ''
      local colour = badge_config['colour'] or badge_config['color']
      if not utils.is_empty(colour) then
        local metaBadgeColour = utils.stringify(colour)
        style = 'style="background-color: ' .. metaBadgeColour .. ';" '
      end

      badgeContent = '<span class="badge rounded-pill quarto-badge ' ..
        metaBadgeClass .. '" ' ..
        style ..
        '>' ..
        displayValue ..
        '</span>'

      break
    end
  end

  return pandoc.RawInline('html', badgeContent)
end

--- Module export table.
--- Defines the shortcode available to Quarto for processing.
--- @type table<string, function>
return {
  ['badge'] = badge
}
