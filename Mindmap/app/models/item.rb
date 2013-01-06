class Item < ActiveRecord::Base
  attr_accessible :description , :name , :parent
  belongs_to :map 
  belongs_to :item
  has_many :items
  acts_as_nested_interval
  
end


