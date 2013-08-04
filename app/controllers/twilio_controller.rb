class TwilioController < ApplicationController
	TWILIO_ACCOUNT_SID = Outsidehacks::Application.config.account_sid
	TWILIO_AUTH_TOKEN = Outsidehacks::Application.config.auth_token
	TWILIO_PHONE_NUMBER = Outsidehacks::Application.config.phone_number

	def index
	end

	def lost
		# Someone loses a XYZ and submits an inquiry.
		# Receive lost_item ID.
		# Check all found_items model to see if anybody turned in an XYZ.

		# Get the following info from 'params[:lost_item]'
		phone_number = LostItem.find(params[:lost_item]).phone_number
		keywords = LostItem.find(params[:lost_item]).keywords

		# Ask FoundItem model for a list of turned in items and their description (matched)
		# Send an SMS to the person inquiring.
		array_of_matched_items = FoundItem.find_matches(keywords)

		# Array of matched items: product, description, location.

		body = ""
		send_sms(phone_number, body)

		render :file => 'app/views/twilio/index.html'
	end

	def found
		# Someone turns in a lost XYZ.
		# Receive found_item ID.
		# Check all lost_items model to see if anybody lost XYZ.

		# Body will be the description of the newly turned in item.
		product = FoundItem.find(params[:found_item]).product
		description = FoundItem.find(params[:found_item]).description
		keywords = FoundItem.find(params[:found_item]).keywords # Array
		location = FoundItem.find(params[:found_item]).location

		body = "New item found: " + product + ", " + description + ", near " + location

		# Ask LostItem model for a list of phone numbers of people who may have lost XYZ.
		# Need to pass: keyword array
		phone_number_arr = LostItem.find_matches(keywords)
		
		# Send out necessary sms.
		phone_number_arr.each do |phone_number|
			send_sms(phone_number, body)
		end

		render :file => 'app/views/twilio/index.html'
	end

	def parse_inbound_sms
		# Receive post request from Twilio.
		body = params[:Body]
		sender = params[:From]

		# Prepare twilio wrapper object.
		twilio_client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

		# HELP and STOP.
		if body.include? "HELP"
			# Respond with help text.
			response = "If you have lost an item, respond with keywords (iPhone5, wallet, "
			response << "keys). Anytime a new item is turned in that matches your keywords, "
			response << "you will receive a text."

			twilio_client.account.sms.messages.create(
				:from => "#{TWILIO_PHONE_NUMBER}",
				:to   => "#{sender}",
				:body => "#{response}"
			)

		elsif body.include? "STOP"
			# Remove phone number records from model.
			LostItem.where(phone_number: sender).delete
		else
			# User texted us keywords.

			# Parse the inbound SMS.
			keywords = body.strip.delete(' ').downcase.split(',')

			# Auto respond to sender.
			# - 'You have successfully subscribed to lost items for keywords: '
			# - 'Reply with HELP or STOP.'
			response = "You have successfully subscribed to lost items tagged: "
			keywords.each do |keyword|
				response << keyword + ", "
			end
			response.slice! response[-2..-1]
			response << ". Reply with HELP for more info or STOP to stop receiving sms."

			# Concatenate response body to be within 160 characters.
			for i in 0..(response.length/160)
				text = response[0, 160]
				response.slice! text
				twilio_client.account.sms.messages.create(
					:from => "#{TWILIO_PHONE_NUMBER}",
					:to   => "#{sender}",
					:body => "#{text}"
				)
			end

			product = ""

			# Insert into model.
			LostItem.create(
				:product => product,
				:phone_number => sender,
				:keywords => keywords
			)
		end

		render :file => 'app/views/twilio/index.html'
	end

	def send_sms(number, body)
		twilio_client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
		twilio_client.account.sms.messages.create(
			:from => "#{TWILIO_PHONE_NUMBER}",
			:to   => "#{number}",
			:body => "#{body}"
		)
	end
end
