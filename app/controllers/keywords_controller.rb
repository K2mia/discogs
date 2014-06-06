class KeywordsController < ApplicationController
  # GET /keywords
  # GET /keywords.json
  def index
    @keywords = Keyword.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @keywords }
    end
  end


  def spider
    @keyword = Keyword.find(params[:id])

    uastr = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.7"

    require 'mechanize'
    agent = Mechanize.new
    agent.user_agent = uastr 
    #agent.user_agent_alias = 'Mac OS X Mozilla'

    discogs_base = "http://www.discogs.com"
    url = "#{discogs_base}/search/?q=Beatles+Sgt+Peppers+LP" 
    page = agent.get url

    @card_ids = Array.new 
    @card_urls = {}
    @card_details = {}
    @card = {}

    cards = page.body.split( /"card card_normal float_fix/ )

    cards.each do |card| 
      if ( /data\-object\-id="(\d+)"/.match( card ) ) 
         cid = $1
         if ( /href="(\S+\/#{$1})"/.match( card ) )
            curl = $1
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
      @card_details[cid] = cdet

      pcont = page.at("#page_content").inner_html
      heads = page.search( ".head" ) 
      contents = page.search( ".content" ) 

      (0..5).each do |i|
         h = heads[i].inner_html
         c = contents[i].text
         c.delete!( "\n" )
         c.strip!
         @card[h] = c 
         #file.write ("[#{i}] (#{h}) cont=(#{c})\n" )
      end

      file = File.open( "/home/andrew/rails_apps/discogs/dump/#{cid}.txt", 'wb' )
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
    @keyword = Keyword.new(params[:keyword])

    respond_to do |format|
      if @keyword.save
        format.html { redirect_to @keyword, notice: 'Keyword was successfully created.' }
        format.json { render json: @keyword, status: :created, location: @keyword }
      else
        format.html { render action: "new" }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /keywords/1
  # PUT /keywords/1.json
  def update
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      if @keyword.update_attributes(params[:keyword])
        format.html { redirect_to @keyword, notice: 'Keyword was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.json
  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to keywords_url }
      format.json { head :no_content }
    end
  end
end
