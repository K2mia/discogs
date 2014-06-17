class UsersController < ApplicationController
  before_filter :signed_in_user,	only: [:index, :edit, :update, :destroy]
  before_filter :correct_user, 		only: [:edit, :update]
  before_filter :admin_user, 		only: [:destroy]


  # Displays the user index page
  def index
    #@users = User.all
    @users = User.paginate( page: params[:page] )
  end

 
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


  # Display the edit form
  def edit
    # note: commented next line since before_filter method defines @user 
    # @user = User.find( params[:id] )
  end

  # Update a User record
  def update
    # note: commented next line since before_filter method defines @user 
    # @user = User.find( params[:id] )

    if @user.update_attributes( params[:user] )
      # Handle successful updateQ
      flash.now[:success] = 'Profile successfully updated'
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Remove a user record
  def destroy
    User.find( params[:user] ).destroy
    flash[:success] = 'You have deleted the user record'
    redirect_to users_path
  end


  # Private method declarations
  private

   # Check for admin user
   def admin_user
     redirect_to( root_path ) unless current_user.admin?
   end

   # If not signed in redirect to sign in
   def signed_in_user
     store_location	# from sessions_helper, store intended location
     redirect_to signin_path, notice: "Please sign in." unless signed_in?
   end

   # Make sure correct user is attempting to edit/update settings
   def correct_user
     @user = User.find( params[:id] )
     redirect_to root_path, notice: "Unauthorized edit/update attempted!" unless current_user?(@user)
   end

end
