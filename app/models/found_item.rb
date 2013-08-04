class FoundItem
  include Mongoid::Document
  include Mongoid::Paperclip
  attr_accessible :claimed_status, :product, :description, :keywords, :image#, :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at

  field :product, type: String
  field :description, type: String
  field :keywords, type: Array
  field :claimed_status, type: Boolean
  field :created_at, type: Date
  field :claimed_at, type: Date
  field :claimed_by, type: String
  field :location_found, type: String

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
end
