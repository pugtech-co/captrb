require 'sqlite3'
require 'fileutils'

module Captrb
  class Database
    def initialize
      @db_path = File.expand_path("~/.captrb/captrb.db")
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
        @db.execute("INSERT INTO embeddings (note_id, vector) VALUES (?, ?)", note_id, vector.to_s)
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
  end
end
