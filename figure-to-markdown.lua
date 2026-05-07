function Figure(fig)
  local img = fig.content[1]

  if img and img.t == "Plain" and img.content[1] and img.content[1].t == "Image" then
    local image = img.content[1]
    local alt_text = pandoc.utils.stringify(image.caption)
    local src = image.src
    local title = image.title or ""

    local caption_text = ""
    if fig.caption and fig.caption.long then
      caption_text = pandoc.utils.stringify(fig.caption.long)
    end

    local markdown_img = ""

    if caption_text ~= "" and alt_text ~= caption_text then
      markdown_img = "![" .. alt_text .. "](" .. src .. ' "' .. caption_text .. '")'
    elseif caption_text ~= "" then
      markdown_img = "![" .. caption_text .. "](" .. src .. ")"
    elseif title ~= "" then
      markdown_img = "![" .. alt_text .. "](" .. src .. ' "' .. title .. '")'
    else
      markdown_img = "![" .. alt_text .. "](" .. src .. ")"
    end

    return pandoc.Para({ pandoc.RawInline("markdown", markdown_img) })
  end

  return fig
end
