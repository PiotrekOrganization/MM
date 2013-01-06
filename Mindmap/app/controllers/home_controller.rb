class HomeController < ApplicationController
	def index
		@items = Item.all
		@maps = Map.all		
	end

	def item 
		@item = Item.find(params[:id])
	end

	def map 
		@map = Map.find(params[:id])
	end

	def items_json	
		@items = Item.all	
		render :json => @items
	end

	
end