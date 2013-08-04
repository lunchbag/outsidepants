class LostItem
  include Mongoid::Document

  field :product, type: String
  field :phone_number, type: String
  field :keywords, type: Array

end
