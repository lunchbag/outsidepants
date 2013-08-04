class FoundItemsController < ApplicationController
  def index
    @found_items = FoundItem.all
  end

  def show
    @found_item = FoundItem.find(params[:id])
  end

  def new
    @found_item = FoundItem.new
  end

  def create
    @found_item = FoundItem.create(params[:found_item])
    @found_item.keywords = convert_keyword_string_to_array(@found_item.keywords)
    @found_item.claimed_status = false
    @found_item.created_at = Time.now
    if @found_item.save
      # respond_to do |format|
      #   format.html
      # end
      redirect_to twilio_url
    else
      redirect_to found_items_url
    end
  end

  def destroy
    @found_item = FoundItem.find(params[:id])
  end
end