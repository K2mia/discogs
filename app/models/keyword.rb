# == Schema Information
#
# Table name: keywords
#
#  id         :integer         not null, primary key
#  keys       :string(255)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Keyword < ActiveRecord::Base
  attr_accessible :keys, :user_id
  belongs_to :user

  validates :keys, :length => { :minimum => 3 }
end
