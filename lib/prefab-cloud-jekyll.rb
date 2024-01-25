require 'fileutils'

require 'prefab/base_block'
require 'prefab/feature_flag'
require 'prefab/variant_default'
require 'prefab/variant'

def snake_to_camel(obj)
  case obj
  when Hash
    obj.each_with_object({}) do |(k, v), result|
      key = k.to_s.gsub(/_([a-z])/) { $1.upcase }
      result[key] = snake_to_camel(v)
    end
  when Array
    obj.map { |v| snake_to_camel(v) }
  else
    obj
  end
end

Jekyll::Hooks.register :pages, :post_render do |page|
  config = snake_to_camel(page.site.config['prefab'])

  source_file = File.expand_path('../prefab.js', __FILE__)
  js_content = File.read(source_file)

  if page.output_ext == '.html'
    script_tags = "
    <script
      src=\"https://cdn.jsdelivr.net/npm/@prefab-cloud/prefab-cloud-js@0.2.3/dist/prefab.bundle.js\"
      type=\"text/javascript\"
    ></script>
    <script type=\"text/javascript\">
      const config = #{config.to_json};
      console.log(config);

      #{js_content}
    </script>
    "
    page.output = page.output.gsub('</head>', "#{script_tags}\n</head>")
  end
end

Liquid::Template.register_tag('feature_flag', Jekyll::FeatureFlagTagBlock)
Liquid::Template.register_tag('variant', Jekyll::VariantTagBlock)
Liquid::Template.register_tag('variant_default', Jekyll::VariantDefaultTagBlock)
