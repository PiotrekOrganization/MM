class DropItemTable < ActiveRecord::Migration
  def up
  	drop_table :items
  end

  def down
	
  end
end
