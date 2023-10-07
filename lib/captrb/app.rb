require 'thor'
require_relative 'config'
require_relative 'database'
require_relative 'calc'
require_relative 'api/completions_client'
require_relative 'api/embeddings_client'

module Captrb
  class App < Thor
    default_command :add
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
      @completions_api = CompletionsClient.new(@config.settings.key)
      @embeddings_api = EmbeddingsClient.new(@config.settings.key)
      @math = Calc.new
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
      note_text, categories, embedding = get_note
      save_note note_text, categories, embedding
    end

    desc "query", "list the top notes related to a query"
    def query(query_string)
      notes = @db.get_all_notes
      query_embedding = @embeddings_api.get_embedding(query_string)

      # Collect embeddings and their corresponding note IDs
      note_embeddings = {}
      notes = @db.get_all_notes
      notes.each do |note|
        note_id = note[0]
        embedding = @db.get_embedding(note_id)
        note_embeddings[note_id] = embedding if embedding
      end
    
      # Get top_n related notes
      top_note_ids, top_scores = @math.strings_ranked_by_relatedness(query_embedding, note_embeddings)
    
      # Print or otherwise use the top related notes
      top_note_ids.each_with_index do |note_id, index|
        note_text = notes.find { |note| note[0] == note_id }[1]
        puts "#{index + 1}: #{note_text} (score: #{top_scores[index]})"
      end
    end

    private

    def get_note
      print "Please enter a note: "
      note_text = STDIN.gets.chomp

      completion = @completions_api.get_completion(note_text, @all_categories)
      embedding = @embeddings_api.get_embedding(note_text)

      if completion.is_a?(Array)
        puts "API Suggested Categories: #{completion.join(', ')}"
      elsif completion.is_a?(String)
        puts "API Completion Doesn't match expected pattern: #{completion}"
        return note_text, []
      end
      return note_text, completion, embedding
    end

    def save_note(note_text, categories, embedding)
      note_id = @db.add_note(note_text)
      categories.each do |category|
        @db.add_category(note_id, category)
      end
      @db.add_embedding(note_id, embedding)
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
      puts "_____________________________________________"

      i = 0
      notes = @db.get_notes(category)

      while true
        break if i >= notes.length
        puts "\nTODO: \033[1m#{notes[i][1]}\033[0m"
        print "Complete (c) or Skip (s) or Quit (q) or Remove Category (r): "
        choice = STDIN.gets.chomp
        if choice == 'c'
          puts "Completing"
          @db.delete_note_and_categories(notes[i][0])
          notes = @db.get_notes(category)
          i = 0
        elsif choice == 's'
          puts "Skipping"
          i += 1
        elsif choice == 'r'
          puts "Removing this note from category: #{category}"
          @db.delete_category_for_note_and_category(notes[i][0], category)
          notes = @db.get_notes(category)
        elsif choice == 'q'
          puts "Quitting"
          break
        else
          puts "Invalid choice"
        end
      end
      puts "Category complete"
    end

    def burn_down_all
      puts "Burning down todo list."
      puts "_______________________"
      i = 0
      notes = @db.get_all_notes_with_categories

      while true
        break if i >= notes.length
        puts "\nTODO: \033[1m#{notes[i][1]}\033[0m"
        puts 
        puts "Suggested types of completion: #{notes[i][2].join(', ')}"
        print "Complete (c) or Skip (s) or Quit (q): "
        choice = STDIN.gets.chomp
        if choice == 'c'
          puts "Completing"
          @db.delete_note_and_categories(notes[i][0])
          notes = @db.get_all_notes_with_categories
          i = 0
        elsif choice == 's'
          puts "Skipping"
          i += 1
        elsif choice == 'q'
          puts "Quitting"
          break
        else
          puts "Invalid choice"
        end
      end
      puts "Burt down todo list"
    end

    def clear_database
      @db.clear_database
    end
  end
end
