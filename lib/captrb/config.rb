require 'yaml'
require 'fileutils'

module Captrb
  class Config
    CONFIG_PATH = File.expand_path("~/.your_app/config.yaml")

    def self.load_or_create
      unless File.exist?(CONFIG_PATH)
        initial_setup
      end
      YAML.load_file(CONFIG_PATH)
    end

    def self.initial_setup
      puts "Initial setup required. Please enter your API key: "
      api_key = gets.strip

      config = {
        'api_key' => api_key
      }

      dir = File.dirname(CONFIG_PATH)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      File.write(CONFIG_PATH, config.to_yaml)
    end
  end
end

