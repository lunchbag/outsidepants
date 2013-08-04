class FoundItem
  include Mongoid::Document
  attr_accessible :claimed_status

  field :description, type: String
  field :keywords, type: Array
  field :claimed_status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String
<<<<<<< HEAD

  def toggle!(field)
	  send "#{field}=", !self.send("#{field}?")
	  save :validation => false
	end

  def toggle_status
    @fi = FoundItem.find(params[:id])
    @fi.toggle!(claimed_status)
  end
end
=======
  field :product, type: String

  def self.find_products_by_product_and_keywords(product, keywords=[])
  	# Receives an array of keywords.
  	# Return an array of matched items (product, desc, location, created_at).
    array_of_matched_items = []
    self.where(product: product).each do |found_item|
      # unless (keywords & found_item.keywords).empty?
        item_text = 'Found: ' + found_item.product + ', ' + found_item.description # + ' at ' + found_item.location_found
        puts item_text
        array_of_matched_items.push(item_text)
      # end
    end
    return array_of_matched_items
  end
end
>>>>>>> twilio
