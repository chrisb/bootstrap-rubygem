require 'bootstrap/version'
require 'popper_js'

module Bootstrap
  module JekyllInjector
    def user_sass_load_paths
      super + [Bootstrap.stylesheets_path]
    end
  end

  class << self
    # Inspired by Kaminari
    def load!
      register_compass_extension if compass?

      if rails?
        register_rails_engine
      elsif hanami?
        register_hanami
      elsif sprockets?
        register_sprockets
      elsif jekyll?
        inject_into_jekyll
      end

      configure_sass
    end

    # Paths
    def gem_path
      @gem_path ||= File.expand_path '..', File.dirname(__FILE__)
    end

    def stylesheets_path
      File.join assets_path, 'stylesheets'
    end

    def javascripts_path
      File.join assets_path, 'javascripts'
    end

    def assets_path
      @assets_path ||= File.join gem_path, 'assets'
    end

    # Environment detection helpers
    def jekyll?
      defined?(::Jekyll::Converters::Scss)
    end

    def sprockets?
      defined?(::Sprockets)
    end

    def compass?
      defined?(::Compass::Frameworks)
    end

    def rails?
      defined?(::Rails)
    end

    def hanami?
      defined?(::Hanami)
    end

    private

    def inject_into_jekyll
      Jekyll::Converters::Scss.prepend(JekyllInjector)
    end

    def configure_sass
      require 'sass'

      ::Sass.load_paths << stylesheets_path
    end

    def register_compass_extension
      ::Compass::Frameworks.register(
          'bootstrap',
          :version               => Bootstrap::VERSION,
          :path                  => gem_path,
          :stylesheets_directory => stylesheets_path,
          :templates_directory   => File.join(gem_path, 'templates')
      )
    end

    def register_rails_engine
      require 'bootstrap/engine'
    end

    def register_sprockets
      Sprockets.append_path(stylesheets_path)
      Sprockets.append_path(javascripts_path)
    end

    def register_hanami
      Hanami::Assets.sources << assets_path
    end
  end
end

Bootstrap.load!
