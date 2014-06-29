class KeywordsController < ApplicationController
  before_filter :signed_in_user,	only: [:create, :destroy]
  before_filter :correct_user,		only: [:spider, :destroy]


  # Run spider on keyword search item
  def spider
    @keyword = Keyword.find(params[:id])

    uastr = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.7"

    require 'mechanize'
    agent = Mechanize.new
    agent.user_agent = uastr 
    #agent.user_agent_alias = 'Mac OS X Mozilla'

    discogs_base = "http://www.discogs.com"
    #url = "#{discogs_base}/search/?q=Beatles+Sgt+Peppers+LP" 
    url = "#{discogs_base}/search/?q=#{CGI.escape @keyword.keys}" 

    #logger.info( "url=(#{url})" )
    #return

    page = agent.get url

    @card_ids = Array.new 
    @card_urls = {}
    @card_details = {}
    @card = {}

    cards = page.body.split( /"card card_normal float_fix/ )

    cards.each do |card| 
      if ( /data\-object\-id="(\d+)"/.match( card ) ) 
         cid = $1
         if ( /href="(\S+\/release\/#{$1})"/.match( card ) )
            curl = $1
            #logger.info( "curl=(#{curl})" )

            @card_ids.push( cid )
            @card_urls[cid] = "#{discogs_base}#{curl}"
         end
      end 
    end

    (0 .. 4).each do |i|
      cid = @card_ids[i]
      curl = @card_urls[cid]
      page = agent.get curl
      cdet = page.body
      #@card_details[cid] = cdet

      pcont = page.at("#page_content").inner_html
      heads = page.search( ".head" ) 
      contents = page.search( ".content" ) 

      #logger.info( "heads=(#{heads.inspect})" )
      #logger.info( "conts=(#{contents.inspect})" )

      (0..5).each do |i|
         h = heads[i].inner_html
         c = contents[i].text
         c.delete!( "\n" )
         c.strip!
         @card[h] = c 
         #file.write ("[#{i}] (#{h}) cont=(#{c})\n" )
      end

      @card_details[cid] = @card.inspect

      root_dir = Rails.root.to_s
      file = File.open( "#{root_dir}/dump/#{cid}.txt", 'wb' )
      file.write ( @card.inspect )
      file.close 

    end


    logger.info ("LOGGER keyword=" + @keyword.inspect )
    #logger.info ("LOGGER page=" + page.body )

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @keyword }
    end
  end


  # GET /keywords/1
  # GET /keywords/1.json
  def show
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/new
  # GET /keywords/new.json
  def new
    @keyword = Keyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/1/edit
  def edit
    @keyword = Keyword.find(params[:id])
  end

  # POST /keywords
  # POST /keywords.json
  def create
    @keyword = current_user.keywords.build( params[:keyword] )

    if @keyword.save
      flash.now[:success] = 'New album search keys created'
      redirect_to root_path
    else
      render 'static/home'
    end
  end


  # Destroy the keyword item
  def destroy
    @keyword.destroy
    redirect_to root_path
  end

  private

   # If not signed in redirect to sign in
   def signed_in_user
     store_location     # from sessions_helper, store intended location
     redirect_to signin_path, notice: "Please sign in." unless signed_in?
   end

   # Make sure we have owner user to be able to take action on their keys
   def correct_user
     @keyword = current_user.keywords.find_by_id( params[:id] )
     redirect_to root_path if @keyword.nil?
   end

end
