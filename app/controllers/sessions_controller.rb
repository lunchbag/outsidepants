class SessionsController < ApplicationController

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

end
