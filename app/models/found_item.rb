class FoundItem
  include Mongoid::Document

  field :product, type: String
  field :description, type: String
  field :keywords, type: Array
  field :status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String
end