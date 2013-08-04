class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin_user
  helper_method :current_user

  def index
  	render "layouts/application"
  end

  def home
    @found_items = FoundItem.all
    @lost_items = LostItem.all

  	render "home/index"
  end

  def donate
    render "home/donate"
  end

  def convert_keyword_string_to_array(keyword_string)
		#keyword_array = keyword_string.delete(' ').downcase.split(',')
	end

	private

		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end

		def current_user
			@current_user ||= User.find(session[:user_id]) if session[:user_id]
		end
end
