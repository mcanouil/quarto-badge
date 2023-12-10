return {
  ['badge'] = function(args, kwargs, meta)
    if quarto.doc.is_format("html") then
      quarto.doc.add_html_dependency({
        name = 'badge',
        stylesheets = {"badge.css"}
      })
      local badgeKey = pandoc.utils.stringify(args[1])
      local badgeValue = pandoc.utils.stringify(args[2])
      local badgeContent = ""
      local metaBadgeHref = ""
      for _, badge in ipairs(meta["badge"]) do
        local metaBadgeKey = pandoc.utils.stringify(badge["key"])
        local metaBadgeClass = pandoc.utils.stringify(badge["class"])
        if metaBadgeKey == badgeKey then
          if badge["href"] ~= "" and badge["href"] ~= nil then
            local metaBadgeHref = pandoc.utils.stringify(badge["href"])
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
          badgeContent = '<span ' .. badgeKey ..
            '" class="badge rounded-pill quarto-badge ' .. metaBadgeClass .. '">' ..
            badgeValue ..
            '</span>'
        end
      end
      return pandoc.RawInline('html', badgeContent)
    end
  end
}
