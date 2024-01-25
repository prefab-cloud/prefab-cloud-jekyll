module Jekyll
  class FeatureFlagTagBlock < Liquid::Block
    def initialize(tag_name, flag_name, tokens)
      super
      @flag_name = flag_name.strip
    end

    def render(context)
      # Set a variable in the context
      context["flag_name"] = @flag_name

      # Render children
      super
    end
  end
end
