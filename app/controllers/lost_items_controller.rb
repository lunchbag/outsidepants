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
    # @lost_item.keywords = convert_keyword_string_to_array(@lost_item.keywords)
    if @lost_item.save
      Tracker.track('lost_items', 'Lost item recorded', {
        'product' => @lost_item.product,
        'via' => 'web'
      })
      redirect_to twilio_lost_url(:lost_item => @lost_item)
      # redirect_to root_url
    else
      flash[:message] = "Phone number and product must both be filled in!"
      redirect_to new_lost_item_url
    end
  end

  def destroy
    phone_number = LostItem.where(_id: params[:id]).first.phone_number || nil
    product = LostItem.where(_id: params[:id]).first.product || nil

    Tracker.track('lost_items', 'Manually deleted', {
      'number' => phone_number,
      'product' => product
    })
    LostItem.where(_id: params[:id]).delete

    flash[:message] = "Successfully unsubscribed " + phone_number + " from " + product
    redirect_to root_url
  end
end
