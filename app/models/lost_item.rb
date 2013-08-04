class LostItem
  include Mongoid::Document

  field :phone_number, type: String
  field :keywords, type: Array
  field :product, type: String

  def self.find_numbers_by_product_and_keywords(product, keywords=[])
  	# Receives an array of keywords.
  	# Returns an array of phone numbers of matches.
    array_of_phone_numbers = []
    self.where(product: product).each do |found_item|
      
      # unless (keywords & found_item.keywords).empty?
        array_of_phone_numbers.push(found_item.phone_number)
        puts found_item.phone_number
      # end
    end
    return array_of_phone_numbers
  end
end