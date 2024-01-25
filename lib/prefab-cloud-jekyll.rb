require 'fileutils'

require 'prefab/config'
require 'prefab/feature_flag'
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
  config = page.site.config['prefab']

  if config['after_evaluation_callback']
    file = File.join(page.site.source, config['after_evaluation_callback'])
    after_evaluation_callback = File.read(file)
  end

  if config['identify_callback']
    file = File.join(page.site.source, config['identify_callback'])
    identify_callback = File.read(file)
  end

  source_file = File.expand_path('../prefab/prefab.js', __FILE__)
  js_content = File.read(source_file)

  if page.output_ext == '.html'
    script_tags = "
    <script
      src=\"https://cdn.jsdelivr.net/npm/@prefab-cloud/prefab-cloud-js@0.2.3/dist/prefab.bundle.js\"
      type=\"text/javascript\"
    ></script>
    <script type=\"text/javascript\">
      const config = #{snake_to_camel(config).to_json};
      
      afterEvaluationCallback = (key, value) => {#{after_evaluation_callback}};
      identifyCallback = (trackingId) => {#{identify_callback}};

      #{js_content}
    </script>
    "
    page.output = page.output.gsub('</head>', "#{script_tags}\n</head>")
  end
end

Liquid::Template.register_tag('config', Jekyll::ConfigTag)
Liquid::Template.register_tag('feature_flag', Jekyll::FeatureFlagTagBlock)
Liquid::Template.register_tag('variant', Jekyll::VariantTagBlock)
