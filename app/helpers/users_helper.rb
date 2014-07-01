module UsersHelper

  def gravatar_for(user, options = { size:50 } )
    gid = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gurl = "https://s.gravatar.com/avatar/#{gid}?s=#{size}"
    #gurl = 'http://mudconnect.com/images/avatars/icculus1.jpg'
    image_tag(gurl, class: 'gravatar_mini' )
  end

end
