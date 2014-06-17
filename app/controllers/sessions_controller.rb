class SessionsController < ApplicationController

  # Used to display the sign in form
  def new
  end

  # Used for signing in a user
  def create
    user = User.find_by_email( params[:session][:email] )
    if user && user.authenticate( params[:session][:password] )
      # sign in the user
      sign_in user
      redirect_back_or user
    else
      # display error message
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  # Used for signing out a user
  def destroy
    sign_out	# find me in sessions_helper
    redirect_to root_path
  end

end
