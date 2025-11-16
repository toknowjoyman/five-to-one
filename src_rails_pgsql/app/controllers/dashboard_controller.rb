class DashboardController < ApplicationController

  def index

    # nontasks button


    # 5 goals - ordered by priority
    @to_do_items = ToDoItem.order(:priority)

    # new task
    @to_do_item = ToDoItem.new

  end

  def goals25
    @to_do_item = ToDoItem.new

    # @todos = ToDoItem.create
  end

  def create
    # debug p
    @to_do_item = ToDoItem.insert([
      { title: params(:title) }
        ])

    # @to_do_item.save
    # p params

  end
end
