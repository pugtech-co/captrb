require 'curses'

require_relative '../views/title_view'
require_relative '../views/footer_view'


module Captrb
  class ApplicationController
    def initialize
      @title_view = TitleView.new(1, Curses.cols, 0, 0)
      @footer_view = FooterView.new(1, Curses.cols, Curses.lines - 1, 0)
    end
  
    def render
      @title_view.render
      @footer_view.render
    end

    def close
      @title_view.close
      @footer_view.close
    end
  end
end