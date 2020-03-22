module ToDoItemsHelper
  def create_multiple_todos   
    @to_do_item = ToDoItem.new(params.require(:to_do_item).permit(:title, :parent))

    @to_do_item.save
    redirect_to @to_do_item
  end
end
