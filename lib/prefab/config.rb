module Jekyll
  class ConfigTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      if markup =~ /^\s*key:(\S+)\s+default:"([^"]+)"\s*$/i
        # If the syntax is with a default value
        @key = $1.strip
        @default = $2
      elsif markup.strip =~ /^\S+$/
        # Basic config shorthand syntax
        @key = markup.strip
        @default = nil
      else
        # If syntax does not match either format, raise a syntax error
        raise SyntaxError, "Syntax Error in 'config' - Valid syntax: {% config key:my-config default:\"some string\" %} or {% config my-config %}"
      end
    end

    def render(context)
      if @default
        # Render with default value inside the span tag
        "<span data-config-name=\"#{@key}\">#{@default}</span>"
      else
        # Render only the key as data attribute
        "<span data-config-name=\"#{@key}\"></span>"
      end
    end
  end
end
