class Keyword < ActiveRecord::Base
  attr_accessible :keys, :user_id
  belongs_to :user

  validates :keys, :length => { :minimum => 3 }
end
