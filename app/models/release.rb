class Release < ActiveRecord::Base
  attr_accessible :country, :format, :genre, :label, :released, :style

  belongs_to :keyword
end
