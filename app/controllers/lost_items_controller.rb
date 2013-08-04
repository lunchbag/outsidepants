class LostItemsController < ApplicationController
  def index
    @lost_items = LostItem.all
  end

  def show
    @lost_item = LostItem.find(params[:id])
  end

  def new
    @lost_item = LostItem.new
  end

  def create
    @lost_item = LostItem.create(params[:lost_item])
    @lost_item.keywords = convert_keyword_string_to_array(@lost_item.keywords)
    if @lost_item.save
      respond_to do |format|
        format.html
      end
    else
      redirect_to index_page
    end
  end

  def destroy
    @lost_item = LostItem.find(params[:id])
  end
end
