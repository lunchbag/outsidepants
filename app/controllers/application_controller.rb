class ApplicationController < ActionController::Base
  protect_from_forgery

  def convert_keyword_string_to_array(keyword_string)
		keyword_array = keyword_string.delete(' ').downcase.split(',')
	end
end
