class TwilioController < ApplicationController
	def index
	end

	def parse_inbound_sms
		# Receive post request from Twilio.
		body = params[:Body]
		sender = params[:From]

		# Parse the inbound SMS.
		# Auto respond to sender.
		# Insert into model.
	end
end
