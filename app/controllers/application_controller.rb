class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin_user
  helper_method :current_user

  require 'mixpanel-ruby'

  def redirect_to_brb
    render "layouts/brb" unless current_user and current_user.admin?
  end

  Tracker = Mixpanel::Tracker.new(Outsidehacks::Application.config.mixpanel_key)

  def index
  	render "layouts/application"
  end

  def not_found
    render "home/404"
  end

  def home
    #@found_items = FoundItem.all

    @claimed_items = FoundItem.where(claimed_status: true)
    @unclaimed_items = FoundItem.where(claimed_status: false).sort_by(&:product)
    @lost_items = LostItem.all

  	render "home/index"
  end

  def donate
    render "home/donate"
  end

  def terms
    render "home/terms"
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
