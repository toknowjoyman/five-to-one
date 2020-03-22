class DashboardController < ApplicationController

def index

  # nontasks button


  # 5 goals
  @to_do_items = ToDoItem.all

  # new task
  @to_do_item = ToDoItem.new

end

def goals25
  @to_do_item = ToDoItem.new
end
end
