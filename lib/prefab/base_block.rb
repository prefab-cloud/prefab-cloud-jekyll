module Jekyll
  class PrefabBaseBlock < Liquid::Block
    def render_with_formatting(content, context)
      # Get the page the tag is being used in
      page = context.registers[:page]

      # Check if the file is a Markdown file
      if page['path'].end_with?('.md', '.markdown')
        # Convert Markdown to HTML
        markdown_converter = context.registers[:site].find_converter_instance(Jekyll::Converters::Markdown)
        markdown_converter.convert(content)
      else
        # For HTML files, the content is left as is
        content
      end
    end
  end
end
