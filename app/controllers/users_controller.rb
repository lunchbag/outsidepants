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
			redirect_to root_url
		else
			redirect_to root_url
		end
	end

	def show
		@user = User.find(params[:id])
	end

end
