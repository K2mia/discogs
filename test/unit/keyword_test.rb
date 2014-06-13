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

require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
