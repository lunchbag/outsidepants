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
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def destroy
    @found_item = FoundItem.find(params[:id])
  end

  def toggle_status
    @fi = FoundItem.find(params[:format])
    if @fi.claimed_status
      @fi.claimed_status = false
    else
      @fi.claimed_status = true
    end
    
    if @fi.save
      redirect_to root_url
    else
      redirect_to '#'
    end
  end
  
end
