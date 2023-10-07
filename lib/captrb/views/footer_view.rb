require_relative 'base_view'

module Captrb
  class FooterView < BaseView
    def render
      @window.attron(Curses.color_pair(1))
      @window.addstr("Press 'q' to quit".center(Curses.cols))
      @window.attroff(Curses.color_pair(1))
      @window.refresh
    end
  end
end