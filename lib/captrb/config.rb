require 'fileutils'
require 'slop'
require 'yaml'

module Captrb
  class Config
    attr_reader :settings

    def initialize
      opts = parse_args
      config = load_config_file(opts[:config])
      opts[:database] = config[:database] unless opts[:database]
      opts[:key] = config[:key] unless opts[:key]
      save_config_file(opts[:config] ,opts[:database], opts[:key])
      @settings = OpenStruct.new(opts)
    end

    def parse_args
      Slop.parse do |o|
        o.string '-c', '--config', 'Specify the configuration file to use.', default: "~/.captrb/config.yaml"
        o.string '-d', '--database', 'Specify the database to use.  Remembers this selection'
        o.string '-k', '--key', 'Specify the OpenAI API key to use.  Remembers this selection'
        o.on '-h', '--help', 'Display this help message.' do
          puts o
          exit
        end
      end.to_hash
    end

    def load_config_file(config_file_path)
      config_file_path = File.expand_path(config_file_path)
      if(File.exist?(config_file_path))
        config_file = File.read(config_file_path)
        config = YAML.load(config_file)
        return config
      else
        puts "Config file not found: #{config_file_path}"
        # get key from user, set database to ~/.captrb/captrb.db
        print "Enter your OpenAI API key: "
        api_key = gets.chomp
        return { database: "~/.captrb/captrb.db", key: api_key }
      end
    end

    def save_config_file(config_file_path, database, api_key)
      config_file_path = File.expand_path(config_file_path)
      dir = File.dirname(config_file_path)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      config = { database: database, key: api_key }
      File.open(config_file_path, 'w') { |f| f.write config.to_yaml }
    end
  end
end
