class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.integer :keyword_id
      t.string :label
      t.string :format
      t.string :country
      t.string :released
      t.string :genre
      t.string :style

      t.timestamps
    end
  end
end
