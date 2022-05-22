class CategoriesController < ApplicationController
  def index
    @categories = current_user.categories
  end

  def new
    @category = Category.new
  end

  def create
    category = Category.new(category_params)
    category.user_id = current_user.id
    category.save

    redirect_to '/categories'
  end

  def edit
    @category = current_user.categories.where(id: params['id']).first
  end

  def update
    category = current_user.categories.where(id: params['id']).first
    category.update(category_params)

    redirect_to '/categories'
  end

  def destroy
    Category.where(id: params['id']).first.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def category_params
    params.require(:category).permit(Category.allowed_params)
  end
end