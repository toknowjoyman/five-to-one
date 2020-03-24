class ToDoItemsController < ApplicationController
  def index
    @to_do_items = ToDoItem.all
    # todos = ToDoItem.insert_all([
    # { title: "cinq", parent: "0", updated_at: Time.now, created_at: Time.now },
    # { title: "sez", parent: "11", updated_at: Time.now, created_at: Time.now}
    #   ])

  end

  def show
    @to_do_item = ToDoItem.find(params[:id])

    @children = ToDoItem.where(parent: @to_do_item.id)

    @parent = ToDoItem.find_by_id(@to_do_item.parent.to_i)

    @new_subTask = ToDoItem.new

    p @children
  end

  def new
    @to_do_item = ToDoItem.new
  end

  def edit
  @article = ToDoItem.find(params[:id])
  @to_do_item = ToDoItem.new
end

  def create
    @to_do_item = ToDoItem.new(params.require(:to_do_item).permit(:title, :parent, :priority))

    @to_do_item.save
    # redirect_to @to_do_item
  end

  def destroy
    @typo = ToDoItem.find(params[:id])
    @typo.destroy

    redirect_to to_do_items_path
  end

  def create_many
    # @to_do_item = ToDoItem.new(params.require(:to_do_item).permit(:title, :parent, :priority))
    #
    # @to_do_item.save
p params
    to_do_item = ToDoItem.insert({title: params[:title], created_at: Time.now, updated_at: Time.now})
  end

end
