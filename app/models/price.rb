class Price < ActiveRecord::Base
  attr_accessible :ebay_id, :ended, :keyword_id, :price

  belongs_to :keyword
end
