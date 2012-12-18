class Item < ActiveRecord::Base
  attr_accessible :description
  belongs_to :map 
  belongs_to :item
  


end
