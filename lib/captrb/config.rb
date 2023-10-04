require 'yaml'
require 'fileutils'
require 'slop'

module Captrb
  class Config
    CONFIG_PATH = File.expand_path("")

    def self.load_or_create
      parse_args

      unless File.exist?(CONFIG_PATH)
        initial_setup
      end
      YAML.load_file(CONFIG_PATH)
    end

    def self.parse_args
      opts = Slop.parse do |o|
        o.string '-c', '--config', 'Specify the configuration file to use.', default: "~/.captrb/config.yaml"
        o.string '-d', '--database', 'Specify the database to use. Remembers this selection', default: "~/.captrb/captrb.db"
        o.string '-k', '--api-key', 'Provide the API key. Remembers this key.'
        o.bool '--list-notes', 'Display existing notes.'
        o.bool '--list-categories', 'List all categories.'
        o.on '-h', '--help', 'Display this help message.' do
          puts o
          exit
        end
      end
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

