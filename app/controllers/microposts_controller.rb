class MicropostsController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy]

	def create
		@micropost = current_user.microposts.new(micropost_params)
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_path
		else
			render "static_page/home"
		end
	end

	def destroy
		
	end

	private
		def micropost_params
			params.require(:micropost).permit(:content)
		end
end
