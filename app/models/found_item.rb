class FoundItem
  include Mongoid::Document
  attr_accessible :claimed_status, :product, :keywords, :description, :location_found, :current_location

  field :product, type: String
  field :description, type: String
  field :keywords, type: Array
  field :claimed_status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String
  field :current_location, type: String

  def toggle!(field)
	  send "#{field}=", !self.send("#{field}?")
	  save :validation => false
	end

  def toggle_status
    @fi = FoundItem.find(params[:id])
    @fi.toggle!(claimed_status)
  end
end
