class AddThumbnailToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :thumbnail, :string
  end
end
