class KeywordsController < ApplicationController
  before_filter :signed_in_user,	only: [:create, :destroy]
  before_filter :correct_user,		only: [:show_releases, :spider_ebay, :spider, :destroy]


  # Display Discogs search results for a keyword
  def show_releases
    @keyword = Keyword.find(params[:id])
    @releases = @keyword.releases.paginate( page: params[:page] )
    prices = @keyword.prices

    @pcount = Price.where( ended:false ).count	# Count for active listings
    @low_price = 10000		# Low price for active listing
    @high_price = 0		# High price for active listing

    @pcount2 = Price.where( ended:true ).count	# Count for ended listings
    @low_price2 = 10000		# Low price for ended listings
    @high_price2 = 0		# High price for ended listings

    prices.each do |prc|
       res = /\$([0-9.,]+)/.match( prc.price )
       pnum = $1.to_f 
       if ( prc.ended )
         @high_price2 = pnum if ( pnum > @high_price2 )
         @low_price2 = pnum if ( pnum < @low_price2 )
       else
         @high_price = pnum if ( pnum > @high_price )
         @low_price = pnum if ( pnum < @low_price )
       end
    end
  end


  # Run Ebay spider on keyword search item
  def spider_ebay
    @keyword = Keyword.find(params[:id])

    uastr = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.7"

    require 'mechanize'
    agent = Mechanize.new
    agent.user_agent = uastr 

    ebay_base = "http://www.ebay.com/sch/i.html"

    # First search active listings
    url = "#{ebay_base}?_nkw=#{CGI.escape @keyword.keys}&_ipg=200" 

    #logger.info( "url=(#{url})" )
    #return

    page = agent.get url
 
    @debug = ""

    page.search("tbody.lyr").each do |tbody_el|
      tbody = tbody_el.inner_html
      res = /<td class="pic p225 lt img" iid="([0-9]+)"/.match( tbody )
      id = $1
      res = /<span style="color:#[0-9]*">(\$[0-9\.,]+)<\/span>/.match( tbody )
      price = $1

      if ( !price.nil? )      
        @price = @keyword.prices.build( { ebay_id: id, ended: false, price: price } )
        @price.save

        #@debug += "id=(#{id}) price=(#{price})<br />\n"
        #@debug += "price=(#{@price.inspect})\n\n"
      end

    end

    # Next search only sold listings
    url2 = "#{ebay_base}?_nkw=#{CGI.escape @keyword.keys}&&_in_kw=1&_ex_kw=&_sacat=0&LH_Sold=1&_udlo=&_udhi=&_samilow=&_samihi=&_sadis=10&_fpos=&_fsct=&LH_SALE_CURRENCY=0&_sop=12&_dmd=1&_ipg=200&LH_Complete=1" 

    page2 = agent.get url2

    page2.search("tbody.lyr").each do |tbody_el|
      tbody = tbody_el.inner_html
      res = /<td class="pic p225 lt img" iid="([0-9]+)"/.match( tbody )
      id = $1
      res = /<span style="color:#[0-9]*">(\$[0-9\.,]+)<\/span>/.match( tbody )
      price = $1


      if ( !price.nil? )
        @price = @keyword.prices.build( { ebay_id: id, ended: true, price: price } )
        @price.save

        #@debug += "id=(#{id}) price=(#{price})<br />\n"
        #@debug += "price=(#{@price.inspect})\n\n"
      end
    end

    show_releases
    render action: 'show_releases', id: @keyword, success: 'Ebay listings scraped'

  end


  # Run Discogs spider on keyword search item
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

    # Check for short-circuit condition with no results
    if ( /find anything in the Discogs database for/.match( page.body ) )
       flash.now[:error] = 'No matches found at Discogs'
       return
    end


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

      ok_fields = ['label', 'format', 'country', 'released', 'genre', 'style']

      (0..5).each do |i|
         h = heads[i].inner_html.downcase.slice(0 .. -2)
         next unless ok_fields.include?( h )

         c = contents[i].text
         c.delete!( "\n" )
         c.strip!
         @card[h] = c 
         #file.write ("[#{i}] (#{h}) cont=(#{c})\n" )
      end


      @card_details[cid] = <<"CARD"
<table>
<tr>
<td width=80>Label:</td>
<td>#{@card['label']}</td>
</tr><tr>
<td>Format:</td>
<td>#{@card['format']}</td>
</tr><tr>
<td>Country:</td>
<td>#{@card['country']}</td>
</tr><tr>
<td>Released:</td>
<td>#{@card['released']}</td>
</tr><tr>
<td>Genre:</td>
<td>#{@card['genre']}</td>
</tr><tr>
<td>Style:</td>
<td>#{@card['style']}</td>
</tr>
</table>
CARD

      @release = @keyword.releases.build( @card )

      if @release.save
        flash.now[:success] = 'Saved release info'
      else
        flash.now[:error] = 'Error saving release info'
      end

      #root_dir = Rails.root.to_s
      #file = File.open( "#{root_dir}/dump/#{cid}.txt", 'wb' )
      #file.write ( @card.inspect )
      #file.close 

    end


    #logger.info ("LOGGER keyword=" + @keyword.inspect )
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
    @keyword.releases.each do |rel|
       rel.destroy
    end
    @keyword.prices.each do |prc|
       prc.destroy
    end

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
