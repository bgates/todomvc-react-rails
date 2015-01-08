class HomeController < ApplicationController
  def index
    @filter = %w(all active completed).find { |i| i == params[:filter] }
    @filter ||= 'all'
    @todos = Todo.all
  end
end
