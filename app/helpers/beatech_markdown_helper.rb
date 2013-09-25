module BeatechMarkdownHelper
  def markdown(text)
    unless @markdown
      beatech_renderer = Redcarpet::Render::BeatechHTML.new(hard_wrap: true, filter_html: true)
      @markdown = Redcarpet::Markdown.new(beatech_renderer, tables: true)
    end

    @markdown.render(text).html_safe
  end

  def render_wiki_content(entry)
    markdown(entry.content)
  end
end