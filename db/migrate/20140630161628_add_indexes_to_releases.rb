class AddIndexesToReleases < ActiveRecord::Migration
  def change
    add_index :releases, :keyword_id
    add_index :releases, :format
    add_index :releases, :label
    add_index :releases, :style
    add_index :releases, :genre
  end
end
