class ToDoItemsController < ApplicationController
  def index
    @to_do_items = ToDoItem.all
  end

  def show
    @to_do_item = ToDoItem.find(params[:id])
  end

  def new
    @to_do_item = ToDoItem.new
  end

  def create
    @to_do_item = ToDoItem.new(params[:to_do_item])

    @to_do_item.save
    redirect_to @to_do_item
  end
end
