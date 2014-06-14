class UsersController < ApplicationController
  
  # Display create new account form
  def new
    @user = User.new
  end

  # Create new user record
  def create
    @user = User.new( params[:user] )
    if @user.save
      # Successful save
      sign_in @user
      flash.now[:success] = 'Welcome to the Prayer Reminder Service'
      redirect_to @user
    else
      render 'new'
    end
  end


  # Display single user profile
  def show
     @user = User.find( params[:id] )
  end

end
