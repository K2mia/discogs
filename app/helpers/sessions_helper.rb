module SessionsHelper

  # Define sign_in method
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user  
  end

  # Define current_user= assignment
  def current_user=(user)
    @current_user = user
  end

  # Define current_user getter ( or = )
  def current_user
    @current_user ||= User.find_by_remember_token( cookies[:remember_token] )
  end

  # Is user logged in
  def signed_in?
    !current_user.nil?
  end

  # Sign the user out
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

end
