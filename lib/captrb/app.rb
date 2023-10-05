# 
# o.string '-c', '--config', 'Specify the configuration file to use.', default: "~/.captrb/config.yaml"
# o.string '-d', '--database', 'Specify the database to use.  Remembers this selection'
# o.string '-k', '--key', 'Specify the OpenAI API key to use.  Remembers this selection'
# o.bool '-b', '--burn-down', 'Burn down todo items.'
# o.bool '-l', '--list', 'List all categorized todo items.'
require 'thor'
require_relative 'config'
require_relative 'database'
require_relative 'api'

module Captrb
  class App < Thor
    class_option :config, type: :string, default: "~/.captrb/config.yaml", desc: 'Specify the configuration file to use', aliases: '-c'
    class_option :database, type: :string, desc: 'Specify the database to use.  Remembers this selection', aliases: '-d'
    class_option :key, type: :string, desc: 'Specify the OpenAI API key to use.  Remembers this selection', aliases: '-k'

    def self.exit_on_failure?
      return true
    end

    # TODO figure out dependency injection with Thor, i think i just add some more params before ARGS
    def initialize(*args)
      super
      @all_categories = ['work', 'personal', 'finance', 'health', 'shopping', 'goodreads']
      @config = Config.new(options)
      @db = Database.new(@config.settings)
    end

    desc "burn_down", "Burn down todo items."
    def burn_down(category=nil)
      if category
        burn_down_category(category)
      else
        burn_down_all
      end
    end

    desc "list", "List all categorized todo items."
    def list
      display_cats
    end

    desc "add", "Add a new todo item."
    def add
      note_text, categories = get_note
      save_note note_text, categories
    end

    private

    def get_note
      print "Please enter a note: "
      note_text = STDIN.gets.chomp

      api_manager = APIManager.new(@config.settings.key)
      completion = api_manager.get_completion(note_text, @all_categories)

      if completion.is_a?(Array)
        puts "API Suggested Categories: #{completion.join(', ')}"
      elsif completion.is_a?(String)
        puts "API Completion Doesn't match expected pattern: #{completion}"
        return note_text, []
      end
      return note_text, completion
    end

    def save_note(note_text, categories)
      note_id = @db.add_note(note_text)
      categories.each do |category|
        @db.add_category(note_id, category)
      end
    end

    def display_cats
      category_note_groups = @db.fetch_categories_and_notes
      category_note_groups.each do |group|
        category, notes = group
        notes_array = notes.split(',')

        puts "Category: #{category}"
        notes_array.each_with_index do |note, index|
          puts "  #{index + 1}: #{note.strip}"
        end
      end
    end

    def burn_down_category(category)
      puts "Burning down todo list for category: #{category}"
      notes = @db.get_notes(category)
      p notes.first
    end

    def burn_down_all
      puts "Burning down todo list"
      note, categories = @db.get_first_note_and_categories
      p note
      p categories
    end
  end
end
