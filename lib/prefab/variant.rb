require 'nokogiri'

module Jekyll
  class VariantTagBlock < Liquid::Block
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

    def initialize(tag_name, param_string, tokens)
      super

      # split in half at the first space
      # limit to two chunks to support spaces in the default value
      params = param_string.strip.split(" ", 2)
      puts params

      if params.length == 1 && params[0] == "default:true"
        @value = nil
        @default = true
      elsif params.length == 1
        @value = params[0]
        @default = false
      elsif params.length == 2 && params[0].start_with?("value:") && params[1] == "default:true"
        @value = params[0].split(":", 2)[1]
        @default = true
      else
        raise SyntaxError, "Syntax Error in 'variant' with params #{param_string} - Valid syntax: {% variant variant-name %} or {% variant default:true %} or {% variant key:variant-name default:true %} "
      end
    end

    def render(context)
      html = render_with_formatting(super, context)

      doc = Nokogiri::HTML::DocumentFragment.parse(html)

      # Select and modify only the immediate children of the root element
      doc.children.each do |child|
        # Add the data attribute if the child is an element
        if child.element?
          child["data-flag-name"] = context["flag_name"]
          child["data-variant"] = @value
          if !@default
            classes = child["class"] ? child["class"].strip + " " : ""
            child["class"] = classes + "prefab-hidden"
          end
        end
      end

      # Render children
      doc.to_html
    end

  end
end
