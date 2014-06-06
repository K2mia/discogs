class User < ActiveRecord::Base
  attr_accessible :email, :name, :pass

  has_many :keywords

  validates_format_of :email, :with => /\S+\@\S+/, :on => :create
  validates :pass, :length => { :minimum => 6 }
  validates :name, :length => { :minimum => 2 }
end
