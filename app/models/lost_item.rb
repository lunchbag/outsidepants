class LostItem
  include Mongoid::Document

  field :product, type: String
  field :phone_number, type: String
  field :keywords, type: Array

  def self.find_matches(keywords)
  	# Receives an array of keywords.
  	# Returns an array of phone numbers of matches.
  	keywords.each do |keyword|
  		# For each keyword, see if any exist in LostItem.
  		
  	end
  end
end