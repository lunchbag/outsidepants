class SessionsController < ApplicationController

  skip_before_filter :redirect_to_brb, :only => [:create]

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      Tracker.track('sessions', 'User logged in')
      session[:user_id] = user.id
      redirect_to root_url
    else
      flash[:message] = "Sorry, wrong username/password combination!"
      Tracker.track('sessions', 'Login fail', {
        'email' => params[:email]
      })
      redirect_to root_url
    end
  end

  def destroy
    Tracker.track('sessions', 'User logged out')
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

end
