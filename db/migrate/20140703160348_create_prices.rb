class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :keyword_id
      t.string :ebay_id
      t.string :price
      t.boolean :ended

      t.timestamps
    end
  end
end
