class TwilioController < ApplicationController
	TWILIO_ACCOUNT_SID = Outsidehacks::Application.config.account_sid
	TWILIO_AUTH_TOKEN = Outsidehacks::Application.config.auth_token
	TWILIO_PHONE_NUMBER = Outsidehacks::Application.config.phone_number

	def index
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
			# Remove phone number from model.
		else
			# User texted us keywords.

			# Parse the inbound SMS.
			keywords = body.strip.split(/[\s,]+/)

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
end
