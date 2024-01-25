module Jekyll
  class VariantTagBlock < PrefabBaseBlock
    def initialize(tag_name, markup, tokens)
      super
      if markup =~ /^\s*value:(\S+)\s+default:"([^"]+)"\s*$/i
        # If the syntax is with a value and a default value
        @value = $1.strip
        @default = $2
      elsif markup =~ /^\s*default:"([^"]+)"\s*$/i
        # If the syntax is with just a default value
        @default = $1
        @value = nil
      elsif markup.strip =~ /^\S+$/
        # Basic config shorthand syntax
        @value = markup.strip
        @default = nil
      else
        # If syntax does not match any expected format, raise a syntax error
        raise SyntaxError, "Syntax Error in 'variant' - Valid syntaxes: {% variant value:my-value default:\"some string\" %}, {% variant default:\"some string\" %}, or {% variant my-value %}"
      end
    end

    def render(context)
      content = render_with_formatting(super, context)

      if @default
        "<div class=\"prefab-variant\" data-flag-name=\"#{context["flag_name"]}\" data-variant=\"#{@value}\">#{content}</div>"
      else
        "<div class=\"prefab-variant\" data-flag-name=\"#{context["flag_name"]}\" data-variant=\"#{@value}\" style=\"display: none\">#{content}</div>"
      end
    end

  end
end
