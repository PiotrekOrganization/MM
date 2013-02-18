class Item < ActiveRecord::Base
  attr_accessible :description , :name 
  belongs_to :map 
  belongs_to :item
  has_many :items
  
  
end


