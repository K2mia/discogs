class AddIndexesToPrices < ActiveRecord::Migration
  def change
    add_index :prices, :keyword_id
    add_index :prices, :ebay_id
    add_index :prices, :ended
  end
end
