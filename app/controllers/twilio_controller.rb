class TwilioController < ApplicationController
	def index
	end

	def parse_inbound_sms
		# Receive post request from Twilio.
		body = params[:Body]
		sender = params[:From]

		puts "sender: " + sender
		puts "body: " + body

		# Parse the inbound SMS.
		# Auto respond to sender.
		# Insert into model.
		render :file => 'app/views/twilio/index.html'
	end
end
