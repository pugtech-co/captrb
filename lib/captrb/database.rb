require 'sqlite3'
require 'fileutils'

module Captrb
  class Database
    def initialize(options)
      @db_path = File.expand_path(options[:database])
      connect
      ensure_tables_exist
    end

    def connect
        dir = File.dirname(@db_path)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
        @db = SQLite3::Database.new(@db_path)
    end

    def ensure_tables_exist
        @db.execute("CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT);")
        @db.execute("CREATE TABLE IF NOT EXISTS embeddings (note_id INTEGER, vector BLOB, FOREIGN KEY(note_id) REFERENCES notes(id));")
        @db.execute("CREATE TABLE IF NOT EXISTS categories (note_id INTEGER, category TEXT, FOREIGN KEY(note_id) REFERENCES notes(id));")
    end

    def add_note(text)
        @db.execute("INSERT INTO notes (text) VALUES (?)", text)
        @db.last_insert_row_id
    end

    def add_embedding(note_id, vector)
      binary_vector = vector.pack("g*")
      @db.execute("INSERT INTO embeddings (note_id, vector) VALUES (?, ?)", note_id, SQLite3::Blob.new(binary_vector))
    end

    def get_embedding(note_id)
      row = @db.get_first_row("SELECT vector FROM embeddings WHERE note_id = ?", note_id)
      if row 
        binary_vector = row[0] 
        array = binary_vector.unpack('g*')
        return array
      end
    end

    def add_category(note_id, category)
        @db.execute("INSERT INTO categories (note_id, category) VALUES (?, ?)", note_id, category)
    end


    def fetch_categories_and_notes
        query = <<-SQL
            SELECT categories.category, GROUP_CONCAT(notes.text)
            FROM categories
            LEFT JOIN notes ON categories.note_id = notes.id
            GROUP BY categories.category;
        SQL
        
        results = @db.execute(query)
        return results
    end

    def get_all_notes
      @db.execute("SELECT * FROM notes")
    end

    def get_all_notes_text
      @db.execute("SELECT text FROM notes")
    end

    def get_notes(category)
      @db.execute("SELECT * FROM notes WHERE id IN (SELECT note_id FROM categories WHERE category = ?)", category)
    end

    def get_note_by_id(note_id)
      @db.execute("SELECT * FROM notes WHERE id = ?", note_id)
    end

    def get_categories_by_note_id(note_id)
      @db.execute("SELECT category FROM categories WHERE note_id = ?", note_id)
    end

    def delete_note_and_categories(note_id)
      @db.execute("DELETE FROM notes WHERE id = ?", note_id)
      @db.execute("DELETE FROM categories WHERE note_id = ?", note_id)
    end

    def get_all_notes_with_categories
      notes = @db.execute("SELECT * FROM notes")
      notes.map do |note|
        categories = @db.execute("SELECT category FROM categories WHERE note_id = ?", note[0])
        note << categories
      end
    end
    
    def get_notes_with_categories_by_category(category)
      notes = @db.execute("SELECT * FROM notes WHERE id IN (SELECT note_id FROM categories WHERE category = ?)", category)
      notes.map do |note|
        categories = @db.execute("SELECT category FROM categories WHERE note_id = ?", note[0])
        note << categories
      end
    end

    def delete_category_for_note_and_category(note_id, category)
      @db.execute("DELETE FROM categories WHERE note_id = ? AND category = ?", note_id, category)
    end


    def get_first_note_and_categories
      note = @db.execute("SELECT * FROM notes LIMIT 1")
      categories = @db.execute("SELECT * FROM categories WHERE note_id = ?", note[0][0])
      return note, categories
    end

    def clear_database
      @db.execute("DELETE FROM notes")
      @db.execute("DELETE FROM categories")
      @db.execute("DELETE FROM embeddings")
    end
  end
end
