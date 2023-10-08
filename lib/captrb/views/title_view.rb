require_relative 'base_view'

module Captrb
  class TitleView < BaseView
    def render
      @window.attron(Curses.color_pair(1))
      @window.addstr("Capt.".center(Curses.cols))
      @window.attroff(Curses.color_pair(1))
      @window.refresh
    end
  end
end