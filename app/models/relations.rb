class Relations < ActiveRecord::Base
  attr_accessible :child_id, :name, :parent_id
  belongs_to :child , :class_name => "Item", :foreign_key => "child_id"
end
