class User::UserController < ApplicationController

	before_filter :authenticate_user!

end