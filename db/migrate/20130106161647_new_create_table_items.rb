class NewCreateTableItems < ActiveRecord::Migration
  def up
  	create_table :items do |t|
	  t.integer :parent_id
	  t.integer :lftp, null: false
	  t.integer :lftq, null: false
	  t.integer :rgtp, null: false
	  t.integer :rgtq, null: false
	  t.decimal :lft, precision: 31, scale: 30, null: false
	  t.decimal :rgt, precision: 31, scale: 30, null: false
	  t.string :name, null: false
	end
	add_index :items, :parent_id
	add_index :items, :lftp
	add_index :items, :lftq
	add_index :items, :lft
	add_index :items, :rgt
  end

  def down
  end
end
