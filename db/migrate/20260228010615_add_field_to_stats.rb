class AddFieldToStats < ActiveRecord::Migration[8.1]
  def change
    add_column :stats, :value, :integer
    add_column :stats, :label, :string
  end
end
