# the burn down view should show the item, the recommended items, and options for completion
# Or it should show all items completed.

require 'curses'

require_relative 'application_controller'
require_relative '../views/burn_down_view'
require_relative '../database'

module Captrb
  class CategoricalBurnDownController < BurnDownController
    def initialize(db, completions_api, embeddings_api, all_categories, calc, category)
      super(db, completions_api, embeddings_api, all_categories, calc)
      @category = category
    end

    def notes_query
      throw "Category not found" unless @all_categories.include?(@category)
      @db.get_notes_with_categories_by_category(@category)
    end
  end
end