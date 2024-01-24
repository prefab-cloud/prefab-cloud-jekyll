require 'fileutils'

require 'prefab/base_block'
require 'prefab/feature_flag'
require 'prefab/variant_default'
require 'prefab/variant'

Jekyll::Hooks.register :site, :post_write do |site|
  source_file = File.expand_path('../prefab.js', __FILE__)
  destination = File.join(site.dest, 'assets')
  
  FileUtils.mkdir_p(destination) unless File.exist?(destination)
  FileUtils.cp(source_file, destination)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  api_key = page.site.config['prefab']['api_key']

  if page.output_ext == '.html'
    script_tag = "
    <script
      src=\"https://cdn.jsdelivr.net/npm/@prefab-cloud/prefab-cloud-js@0.2.3/dist/prefab.bundle.js\"
      type=\"text/javascript\"
    ></script>
    <script type=\"text/javascript\">
      window.prefabPlugin = {
        apiKey: \"#{api_key}\",
        // TODO: forward all client config props
      };
    </script>
    <script src=\"/assets/prefab.js\" type=\"text/javascript\"></script>
    "
    page.output = page.output.gsub('</head>', "#{script_tag}\n</head>")
  end
end

Liquid::Template.register_tag('feature_flag', Jekyll::FeatureFlagTagBlock)
Liquid::Template.register_tag('variant', Jekyll::VariantTagBlock)
Liquid::Template.register_tag('variant_default', Jekyll::VariantDefaultTagBlock)
