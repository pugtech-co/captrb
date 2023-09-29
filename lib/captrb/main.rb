require_relative 'config'

module Captrb
  class Main
    def self.run
      config = Config.load_or_create
      api_key = config['api_key']

      # Your main logic here
      print api_key
      print "\n"
    end
  end
end

