class FoundItemsController < ApplicationController

  # not used?
  def index
    @found_items = FoundItem.all
  end

  def show
    @found_item = FoundItem.find(params[:id])
  end

  def new
    @found_item = FoundItem.new
    @found_item.product = 'phone'
    @found_item.current_location = 'marx meadow'
  end

  def create
    @found_item = FoundItem.new(params[:found_item])
    @found_item.claimed_status = false
    @found_item.created_at = Time.now

    latest = FoundItem.last
    if latest.nil?
      @found_item.item_id = 308
    else
      @found_item.item_id = latest.item_id.to_i + 1
    end
    
    if @found_item.save
      # respond_to do |format|
      #   format.html
      # end
      Tracker.track('found_items', 'Found item recorded', {
        'product' => @found_item.product
      })
      redirect_to twilio_found_url(:found_item => @found_item)
      # redirect_to root_url
    else
      flash[:message] = "Description and Location Found must both be filled in!"
      redirect_to new_found_item_url
    end
  end

  def edit
    @update = true
    # Edit the found item.
    @found_item = FoundItem.find(params[:id])
  end

  def update
    # Update the found item.
    @found_item = FoundItem.find(params[:id])

    if @found_item.update_attributes(params[:found_item])
      redirect_to twilio_found_url(:found_item => @found_item)
    else
      flash[:message] = "Description and Location Found must both be filled in!"
      redirect_to edit_found_item_url(params[:id])
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
      Tracker.track('found_items', 'Found item claimed', {
        'product' => @fi.product
      })
      redirect_to donate_url
    else
      redirect_to '#'
    end
  end
  
end
