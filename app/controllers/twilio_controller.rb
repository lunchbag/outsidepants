class TwilioController < ApplicationController
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

		# Insert into model.
		LostItem.create(
			:product => product,
			:phone_number => sender,
			:keywords => keywords
		)

		render :file => 'app/views/twilio/index.html'
	end
end
