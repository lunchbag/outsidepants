class TwilioController < ApplicationController
  require 'mixpanel-ruby'

  TWILIO_ACCOUNT_SID = Outsidehacks::Application.config.account_sid
  TWILIO_AUTH_TOKEN = Outsidehacks::Application.config.auth_token
  TWILIO_PHONE_NUMBER = Outsidehacks::Application.config.phone_number

  Tracker = Mixpanel::Tracker.new(Outsidehacks::Application.config.mixpanel_key)

  PRODUCTS = ['phone', 'wallet', 'bag', 'camera', 'keys', 'cards', 'misc']

  def index
  end

  def lost
    # Someone loses a XYZ and submits an inquiry.
    # Receive lost_item ID.
    # Check all found_items model to see if anybody turned in an XYZ.

    # Get the following info from 'params[:lost_item]'
    phone_number = LostItem.find(params[:lost_item]).phone_number
    keywords = LostItem.find(params[:lost_item]).keywords
    product = LostItem.find(params[:lost_item]).product

    # Ask FoundItem model for a list of turned in items and their description (matched)
    # Send an SMS to the person inquiring.
    array_of_matched_items = FoundItem.find_products_by_product_and_keywords(product, keywords)

    # Array of matched items: product, description, location.
    array_of_matched_items.each do |matched_item|
      send_sms(phone_number, matched_item, "existing found")
    end

    redirect_to root_url
  end

  def found
    # Someone turns in a lost XYZ.
    # Receive found_item ID.
    # Check all lost_items model to see if anybody lost XYZ.

    # Body will be the description of the newly turned in item.
    item = FoundItem.find(params[:found_item]);

    body = "FOUND " + item.product.upcase + " (" + item.description[0..25] + "..) " + " @" + item.location_found + "; text 'INFO " + item.item_id.to_s + "' for details."

    # Ask LostItem model for a list of phone numbers of people who may have lost XYZ.
    # Need to pass: keyword array
    phone_number_arr = LostItem.find_numbers_by_product_and_keywords(item.product, item.keywords)

    # Send out necessary sms.
    phone_number_arr.each do |phone_number|
      puts "body: " + body.to_s
      puts "phone number: " + phone_number.to_s
      send_sms(phone_number, body, 'found')
    end

    redirect_to root_url
  end

  def parse_inbound_sms
    # Receive post request from Twilio.
    body = params[:Body].downcase.strip
    sender = params[:From]
    Tracker.people.set(sender, {
      '$phone_number' => sender,
    })

    # Keywords: LOST, ASSIST, END, INFO
    if body.start_with?("assist")
      Tracker.track(sender, 'Text message received', {
        'keyword' => 'assist',
        'body' => body
      })
      puts "ASSIST"
      response = ""
      #temp = "" + body
      #temp.slice! "assist"
      #temp.strip!

      # If just one word, respond with help text.
      #if body.eql? "assist"
      response << "Text back in this format: \"Lost <CATEGORY>\"  " #: <KEYWORD>, <KEYWORD>.."
      response << "Categories: Phone, Wallet, Bag, Camera, Keys, Cards, Misc.  Example: \"Lost phone\". "
      response << "Reply HALT to stop messages."
        #response << " ASSIST <CATEGORY> for suggested keywords."
=begin
        elsif PRODUCTS.include?(temp)
        # Return popular keywords for that product.
        case temp
        when "phone"
          response << "LOST phone: iphone, android, moto razr, white, black, old, new, case"
        when "wallet"
          response << "LOST wallet: leather, black, brown, chain, canvas, zipper, tri-fold"
        when "bag"
          response << "LOST bag: leather, backpack, black, white, zipper, canvas, fabric, buckle"
        when "camera"
          response << "LOST camera: digital, sony, canon, analog, disposable, instagram, new, used"
        when "keys"
          response << "LOST keys: honda, toyota, keychain, bottle opener"
        when "cards"
          response << "LOST cards: california license, fake id, bank of america, starbucks giftcard"
        else
          response << "LOST misc: potato, pants, left shoe"
        end
      else
        response << "Sorry, we were unable to understand your request. Try 'ASSIST <Category>'. "
        response << "Categories: Phone, Wallet, Bag, Camera, Keys, Cards, Misc."
=end

      #end
      send_sms(sender, response, 'assist')
    elsif body.start_with?("info")
      Tracker.track(sender, 'Text message received', {
        'keyword' => 'info',
        'body' => body
      })
      puts "INFO"
      body.slice! "info"
      keywords = body.strip.delete(' ').downcase.split(/[\:\,]/)
      found_item = FoundItem.where(item_id: keywords[0].to_i).first
      response = ""

      if (found_item.image.present?)
        response << "Image: " + found_item.image.url(:large)
      end

      if (found_item.current_location == "marx meadow")
        response << " Pick up @ Marx Meadow: http://goo.gl/hDHcXQ"
      else
        response << " Pick up @ Polo Field: http://goo.gl/fpnZ3b"
      end

      send_sms(sender, response, 'info')

    elsif body.start_with?("halt")
      Tracker.track(sender, 'Text message received', {
        'keyword' => 'halt',
        'body' => body
      })
      puts "HALT"
      response = ""

      response << "You are now unsubscribed from all LOST alerts! Reply LOST <CATEGORY>"
      response << " to subscribe to new SMS updates."
      send_sms(sender, response, 'unsubscribed')

      # Remove phone number records from model.
      LostItem.where(phone_number: sender).delete
    elsif body.start_with?("lost")
      Tracker.track(sender, 'Text message received', {
        'keyword' => 'lost',
        'body' => body
      })
      # User texted us keywords.
      # LOST <CATEGORY> <KEYWORD>, <KEYWORD>
      body.slice! "lost"

      # Parse the inbound SMS.
      keywords = body.strip.delete(' ').downcase.split(/[\:\,]/)
      puts 'keywords: '
      puts keywords
      if PRODUCTS.include?(keywords[0])
        # Auto respond to sender.
        # - 'You have successfully subscribed to lost items for keywords: '
        response = "You have successfully subscribed to SMS updates for lost "
        response << keywords[0]
        response << ". Reply with ASSIST for more info or HALT to stop receiving."

        Tracker.track('lost_items', 'Lost item recorded', {
          'product' => keywords[0],
          'via' => 'text',
          'phone_number' => sender
        })

        # Concatenate response body to be within 160 characters.
        send_sms(sender, response, 'lost confirmation')

        # Add into the database
        @lost_item = LostItem.create(
          :phone_number => sender,
          :keywords => keywords[1..-1],
          :product => keywords[0]
        )

        # Trigger search for found items.
        # redirect_to twilio_lost_url(:lost_item => @lost_item)

        # Ask FoundItem model for a list of turned in items and their description (matched)
        # Send an SMS to the person inquiring.
        array_of_matched_items = FoundItem.find_products_by_product_and_keywords(keywords[0], keywords[1..-1])

        # Array of matched items: product, description, location.
        array_of_matched_items.each do |matched_item|
          send_sms(sender, matched_item, 'existing found')
        end
      else
        Tracker.track(sender, 'Unrecognized text message received', {
          'body' => body
        })
        text = "We weren't able to recognize your lost item inquiry. "
        text << "Text ASSIST to learn how to submit a lost item request."
        # Fail, send help message to user
        send_sms(sender, text, 'unrecognized')
      end
    else
      Tracker.track(sender, 'Unrecognized text message received', {
        'body' => body
      })
      text = "We weren't able to recognize your lost item inquiry. "
      text << "Text ASSIST to learn how to submit a lost item request."
      send_sms(sender, text, 'unrecognized')
    end

    render :file => 'app/views/twilio/index.html'
  end

  def send_sms(number, body, type='')
    begin
      twilio_client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
      new_body = body + ""
      for i in 0..(body.length/160)
        text = new_body[0, 160]
        new_body.slice! text
        twilio_client.account.sms.messages.create(
          :from => "#{TWILIO_PHONE_NUMBER}",
          :to   => "#{number}",
          :body => "#{text}"
        )
      end
      Tracker.track(number, 'Text message sent', {
        'type' => type,
        'body' => body
      })
    rescue
      Tracker.track(number, 'Text message could not be sent', {
        'number' => number,
        'body' => body,
        'type' => type
      })
    end
  end
end