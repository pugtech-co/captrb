require_relative 'config'
require_relative 'database'
require_relative 'api'

module Captrb
  class Main
    def initialize
      @all_categories = ['work', 'personal', 'finance', 'health', 'shopping', 'goodreads']
      @config = Config.new
      @db = Database.new
    end

    def run
      if @config.settings.list
        display_cats
        return  
      elsif @config.settings.burn_down
        burn_down
        return
      else
        note_text, categories = get_note
        save_note note_text, categories
      end
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

    def burn_down
      puts "Burning down todo list"
      note, categories = @db.get_first_note_and_categories
      p note
      p categories
    end
  end
end
