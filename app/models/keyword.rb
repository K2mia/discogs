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
  attr_accessible :keys
  belongs_to :user
  has_many :releases

  validates :user_id, presence: true
  validates :keys, :length => { :minimum => 3 }

  default_scope order: 'keywords.created_at DESC'
end
