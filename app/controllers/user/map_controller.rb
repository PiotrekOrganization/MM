class User::MapController < User::UserController
	
	layout 'map', :only => [ :show ]
	
	def show
		@map = Map.find(params[:id])
	end

	def index
		@maps  = current_user.maps
	 
	end

	def new
		@map = Map.new
	end

	def edit
		@map = Map.find(params[:id])
	end

	def update
		@map = Map.find(params[:id])
		@map.update_attributes!(params[:map])
		redirect_to user_map_index_path(@user) , :alert => "map updated"
	rescue ActiveRecord::RecordInvalid
		render "edit"
	end
	
	def create
		@map = Map.new(params[:map])
		@map.save!
		redirect_to user_map_index_path(@user) , :alert => "map created"
	rescue ActiveRecord::RecordInvalid
		render "new"
	end

	def destroy
		@map = Map.find(params[:id]).destroy
		redirect_to user_map_index_path , :alert => "map deleted"
	rescue ActiveRecord::RecordNotFound
		redirect_to user_map_index_path , :alert => "map not Found"
	end


	
	


end