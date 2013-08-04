class FoundItem
  include Mongoid::Document
  include Mongoid::Paperclip
  attr_accessible :claimed_status, :product, :description, :keywords, :image, :location_found, :current_location
  
  field :description, type: String
  field :keywords, type: Array
  field :claimed_status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String
  field :current_location, type: String

  has_mongoid_attached_file :image, 
    styles: {
      thumb: '100x100#',
      large: '700x700>'
    },
    #content_type: [ "image/jpg", "image/png", "image/bmp" ],
    path: "photos/:date/:id/:style/:filename",
    storage: :s3,
    bucket: 'outsidepants',
    s3_credentials: Rails.root.join("config/s3.yml")

  def toggle!(field)
	  send "#{field}=", !self.send("#{field}?")
	  save :validation => false
	end

  def toggle_status
    @fi = FoundItem.find(params[:id])
    @fi.toggle!(claimed_status)
  end

  field :product, type: String

  def self.find_products_by_product_and_keywords(product, keywords=[])
  	# Receives an array of keywords.
  	# Return an array of matched items (product, desc, location, created_at).
    array_of_matched_items = []
    self.where(product: product).each do |found_item|
      # unless (keywords & found_item.keywords).empty?
        # item_text = 'Found: ' + found_item.product + ', ' + found_item.description # + ' at ' + found_item.location_found
        item_text = "FOUND " + found_item.product.upcase + "(" + found_item.description + ")" + " @" + found_item.location_found + ", now @ " + found_item.current_location
        # puts item_text
        array_of_matched_items.push(item_text)
      # end
    end
    return array_of_matched_items
  end
end
