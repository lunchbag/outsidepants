class FoundItem
  include Mongoid::Document

  field :product, type: String
  field :description, type: String
  field :keywords, type: Array
  field :claimed_status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String

  def self.find_matches(keywords)
  	# Receives an array of keywords.
  	# Return an array of matched items (product, desc, location, created_at).

  end
end