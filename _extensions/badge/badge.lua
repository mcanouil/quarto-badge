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

--- Load utils module
local utils_path = quarto.utils.resolve_path("_modules/utils.lua")
local utils = require(utils_path)

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
  if quarto.doc.is_format("html") then
    quarto.doc.add_html_dependency({
      name = 'badge',
      stylesheets = { "badge.css" }
    })
    --- @type string Badge key from metadata
    local badgeKey = utils.stringify(args[1])
    --- @type string Badge value/content to display
    local badgeValue = utils.stringify(args[2])
    --- @type string HTML content for the badge
    local badgeContent = ""
    for _, badge in ipairs(meta["badge"]) do
      --- @type string Badge key from metadata entry
      local metaBadgeKey = utils.stringify(badge["key"])
      --- @type string CSS class for the badge
      local metaBadgeClass = ""
      if badge["class"] ~= "" and badge["class"] ~= nil then
        metaBadgeClass = utils.stringify(badge["class"])
      end
      if metaBadgeKey == badgeKey then
        if badge["href"] ~= "" and badge["href"] ~= nil then
          --- @type string Hyperlink URL for the badge
          local metaBadgeHref = utils.stringify(badge["href"])
          if metaBadgeHref:find("{{value}}") then
            metaBadgeHref = metaBadgeHref:gsub("{{value}}", badgeValue)
          end
          badgeValue = '<a ' ..
              'href="' .. metaBadgeHref .. '"' ..
              'class="quarto-badge-href"' ..
              '>' ..
              badgeValue ..
              '</a>'
        end
        --- @type string Custom style attribute for badge colour
        local style = ""
        if (badge["colour"] ~= "" and badge["colour"] ~= nil) or (badge["color"] ~= "" and badge["color"] ~= nil) then
          metaBadgeColor = utils.stringify(badge["colour"] or badge["color"])
          style = 'style="background-color: ' .. metaBadgeColor .. ';' .. '"'
        end
        badgeContent = '<span class="badge rounded-pill quarto-badge ' .. metaBadgeClass .. '" ' .. style .. '>' ..
            badgeValue ..
            '</span>'
      end
    end
    return pandoc.RawInline('html', badgeContent)
  end
end

--- Module export table.
--- Defines the shortcode available to Quarto for processing.
--- @type table<string, function>
return {
  ['badge'] = badge
}
