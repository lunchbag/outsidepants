class FoundItemsController < ApplicationController

  #require 'mixpanel-ruby'

  #Tracker = Mixpanel::Tracker.new("9c33be990f3f843538678ff0f984835d")


  # not used?
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
    @found_item = FoundItem.new(params[:found_item])
    #@found_item.keywords = convert_keyword_string_to_array(@found_item.keywords)
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
      Tracker.track('found_items', 'Found ' + @found_item.product + ' recorded')
      Tracker.track('found_items', 'Found item recorded')
      redirect_to twilio_found_url(:found_item => @found_item)
      # redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def edit
    # Edit the found item.
    @found_item = FoundItem.find(params[:id])
  end

  def update
    # Update the found item.
    @found_item = FoundItem.find(params[:id])

    if @found_item.update_attributes(params[:found_item])
      redirect_to twilio_found_url(:found_item => @found_item)
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
      Tracker.track('found_items', 'Found ' + @fi.product + ' claimed')
      Tracker.track('found_items', 'Found item claimed')
      redirect_to donate_url
    else
      redirect_to '#'
    end
  end
  
end
