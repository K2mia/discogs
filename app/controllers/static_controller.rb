class StaticController < ApplicationController
  def home
    if signed_in?
      @keyword = current_user.keywords.build
      @feed_items = current_user.feed.paginate( page: params[:page] )
    end
  end

  def help
  end

  def about
  end

  def contact
  end

end
