require_relative 'config'
require_relative 'database'
require_relative 'api'


module Captrb
  class Main
    def self.run
      all_categories = ['work', 'personal', 'finance', 'health', 'shopping', 'goodreads']

      config = Config.new
      api_key = config.settings.api_key

      db = Database.new

      note_text, categories = get_note api_key, all_categories
      save_note db, note_text, categories
      display_cats(db)
    end

    def self.get_note(api_key, categories)
      print "Please enter a note: "
      note_text = STDIN.gets.chomp

      api_manager = APIManager.new(api_key)
      completion = api_manager.get_completion(note_text, categories)

      if completion.is_a?(Array)
        ts "API Suggested Categories: #{completion.join(', ')}"
      elsif completion.is_a?(String)
        puts "API Completion Doesn't match expected pattern: #{completion}"
        return note_text, []
      end
      return note_text, completion
    end

    def self.save_note(db, note_text, categories)
      note_id = db.add_note(note_text)
      categories.each do |category|
        db.add_category(note_id, category)
      end
    end

    def self.display_cats(db)
      category_note_groups = db.fetch_categories_and_notes
      category_note_groups.each do |group|
        category, notes = group
        notes_array = notes.split(',')
        
        puts "Category: #{category}"
        notes_array.each_with_index do |note, index|
          puts "  #{index + 1}: #{note.strip}"
        end
      end
    end

  end
end

