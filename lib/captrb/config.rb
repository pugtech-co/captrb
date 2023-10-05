require 'fileutils'
require 'yaml'

module Captrb
  # Config class is responsible for loading and saving the config file.
  # Thor passes in the options hash, which is used to load the config file.
  # This then puts the options and configs into an OpenStruct object. 

  class Config
    attr_reader :settings

    def initialize(options)
      config = load_config_file(options[:config])
      config[:database] = config[:database] unless options[:database]
      config[:key] = config[:key] unless options[:key]
      save_config_file(options[:config] ,config[:database], config[:key])
      @settings = OpenStruct.new(config)
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
        api_key = STDIN.gets.chomp
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
