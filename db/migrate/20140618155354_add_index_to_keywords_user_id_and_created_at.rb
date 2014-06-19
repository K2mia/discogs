class AddIndexToKeywordsUserIdAndCreatedAt < ActiveRecord::Migration
  def change
    add_index :keywords, [:user_id, :created_at]
  end
end
