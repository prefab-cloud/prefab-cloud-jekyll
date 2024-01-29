module Jekyll
  class ConfigTag < Liquid::Tag
    def initialize(tag_name, param_string, tokens)
      super

      # split in half at the first space
      # limit to two chunks to support spaces in the default value
      params = param_string.strip.split(" ", 2)
      puts params

      if params.length == 1
        @key = params[0]
        @default = nil
      elsif params.length == 2 && params[0].start_with?("key:") && params[1].start_with?("default:")
        @key = params[0].split(":", 2)[1]
        @default = params[1].split(":", 2)[1]
      else
        raise SyntaxError, "Syntax Error in 'config' with params #{param_string} - Valid syntax: {% config config-name %} or {% config key:config-name default:some string %} "
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
