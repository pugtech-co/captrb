require_relative 'config'
require_relative 'database'
require_relative 'api'

module Captrb
  class Main
    def self.run

      config = Config.new
      api_key = config.settings.api_key

      db = Database.new

      print "Please enter a note: "
      note_text = gets.chomp
      note_id = db.add_note(note_text)
      categories = ['work', 'personal', 'finance', 'health', 'shopping', 'goodreads']

      # Initialize APIManager
      api_manager = APIManager.new(api_key)

      # Get a completion from OpenAI
      completion = api_manager.get_completion(note_text, categories)

      if completion.is_a?(Array)
        puts "API Suggested Categories: #{completion.join(', ')}"
      elsif completion.is_a?(String)
        puts "API Completion: #{completion}"
        return
      end

      # Add categories to note
      completion.each do |category|
        db.add_category(note_id, category)
      end

      display_cats(db)
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

