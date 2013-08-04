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

		# Parse the inbound SMS.
		keywords = body.strip.split(/\s+/)

		# Auto respond to sender.
		# - 'You have successfully subscribed to lost items for keywords: '
		# - 'Reply with HELP or STOP.'
		twilio_client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
		twilio_client.account.sms.messages.create(
			:from => "#{TWILIO_PHONE_NUMBER}",
			:to   => "#{sender}",
			:body => "#{body}"
		)

		# Insert into model.
		LostItem.create(
			:product => product,
			:phone_number => sender,
			:keywords => keywords
		)

		render :file => 'app/views/twilio/index.html'
	end
end
