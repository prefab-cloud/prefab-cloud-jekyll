module Jekyll
  class VariantTagBlock < PrefabBaseBlock
    def initialize(tag_name, variant, tokens)
      super
      @variant = variant.strip
    end

    def render(context)
      content = render_with_formatting(super, context)

      "<div class=\"prefab-variant\" data-flag-name=\"#{context["flag_name"]}\" data-variant=\"#{@variant}\" style=\"display: none\">#{content}</div>"
    end

  end
end
