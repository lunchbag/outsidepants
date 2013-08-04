class UsersController < ApplicationController

	def index
		@users = User.all
	end

	def new
		@user = User.new
	end

	def create
		@user = User.create(params[:user])
		@user.admin = false
		if @user.save
			redirect_to show_user_page
		else
			redirect_to 
		end
	end

	def show
		@user = User.find(params[:id])
	end

end
