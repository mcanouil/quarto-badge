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
        version_badge_content = pandoc.utils.stringify(meta["version-badge"])
        if version_badge_content == version_text then
          css_class = "badge-prerelease bg-danger"
        else 
          css_class = "badge-release bg-success"
        end
      else
        css_class = "badge-release bg-success"
      end
        
      local style = pandoc.utils.stringify(kwargs['style'])
      if style then
        style_text = ' style="' .. style .. '"'
      else
        style_text = ""
      end

      return pandoc.RawInline(
        'html',
        '<span class="badge rounded-pill ' .. css_class .. '"' .. style_text .. '>' .. 'v' .. version_text .. '</span>'
      )
    end
  end
}
