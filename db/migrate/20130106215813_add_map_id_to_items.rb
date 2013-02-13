class AddMapIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :map_id, :integer
  end
end
