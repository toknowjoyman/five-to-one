class ToDoItemsController < ApplicationController
  def index
    @to_do_items = ToDoItem.all
  end

  def show
    @to_do_item = ToDoItem.find(params[:id])
    @children = ToDoItem.find_by_parent(params[:id])
    @parent = ToDoItem.find_by_id(@to_do_item.parent.to_i)
    @new_subTask = ToDoItem.new
  end

  def new
    @to_do_item = ToDoItem.new
  end

  def edit
  @article = ToDoItem.find(params[:id])
end

  def create
    @to_do_item = ToDoItem.new(params.require(:to_do_item).permit(:title, :parent, :priority))

    @to_do_item.save
    redirect_to @to_do_item
  end

  def destroy
    @typo = ToDoItem.find(params[:id])
    @typo.destroy

    redirect_to to_do_items_path
  end

  def create_many(number)
  end

end
