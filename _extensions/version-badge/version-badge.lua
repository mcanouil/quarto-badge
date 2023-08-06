--[[
# MIT License
#
# Copyright (c) Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

return {
  ['v'] = function(args, kwargs, meta)
    if quarto.doc.is_format("html") then
      quarto.doc.add_html_dependency({
        name = 'version-badge',
        version = '1.0.0',
        stylesheets = {"version-badge.css"}
      })

      local version_text = pandoc.utils.stringify(args[1])
      if meta["version-badge"] then
        if meta["version-badge"]["version"] then
          version_badge_content = pandoc.utils.stringify(meta["version-badge"]["version"])
        else
          version_badge_content = pandoc.utils.stringify(meta["version-badge"])
        end
        if meta["version-badge"]["type"] then
          type_badge_content = pandoc.utils.stringify(meta["version-badge"]["type"])
        else
          type_badge_content = "pre-release"
        end
        if meta["version-badge"]["default"] then
          default_type_badge_content = pandoc.utils.stringify(meta["version-badge"]["default"])
        else
          default_type_badge_content = "release"
        end

        if version_badge_content == version_text then
          css_class = "badge-target bg-danger"
          version_type = ' title="' .. type_badge_content .. '"'
        else 
          css_class = "badge-default bg-success"
          version_type = ' title="' .. default_type_badge_content .. '"'
        end
      else
        css_class = "badge-default bg-success"
        version_type = ' title="' .. default_type_badge_content .. '"'
      end
        
      local style = pandoc.utils.stringify(kwargs['style'])
      if style ~= "" then
        style_text = ' style="' .. style .. '"'
      else
        style_text = ""
      end

      version_text = 'v' .. version_text
      if meta["version-badge"]["changelog"] ~= "" and meta["version-badge"]["changelog"] ~= nil then
        changelog = pandoc.utils.stringify(meta["version-badge"]["changelog"])
        version_text = '<a ' ..
          'href="' .. changelog:gsub("{{version}}", version_text) .. '"' ..
          'style="text-decoration: none; color: inherit;"' ..
        '>' ..
        version_text ..
        '</a>'
      end

      return pandoc.RawInline(
        'html',
        '<span id="#badge-version" class="badge rounded-pill ' ..
          css_class .. '"' .. style_text ..
          version_type ..
        '>' ..
        version_text ..
        '</span>'
      )
    end
  end
}
