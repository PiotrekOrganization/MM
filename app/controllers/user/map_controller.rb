class User::MapController < User::UserController
	
	layout 'map', :only => [ :show ]
	
	def show
		@map = Map.find(params[:id])
	end

	def index
		@maps  = Map.all	
	 
	end

	
	


end