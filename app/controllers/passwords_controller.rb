class PasswordsController < Devise::PasswordsController
	skip_before_filter :authenticate_seller_from_token!, only: [:create, :edit, :update]

	def create
		self.resource = resource_class.send_reset_password_instructions(resource_params)
	    yield resource if block_given?

	    if successfully_sent?(resource)
	      render json: {}, status: :ok
	    else
	      render json: resource, status: :unprocessable_entity
	    end
	end

	def update
		self.resource = resource_class.reset_password_by_token(resource_params)
	    yield resource if block_given?

	    if resource.errors.empty?
	      resource.unlock_access! if unlockable?(resource)
	      if Devise.sign_in_after_reset_password
	        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
	        set_flash_message(:notice, flash_message) if is_flashing_format?
	      else
	        set_flash_message(:notice, :updated_not_active) if is_flashing_format?
	      end
	      respond_with resource, location: after_resetting_password_path_for(resource)
	    else
	      set_minimum_password_length
	      respond_with resource
	    end
	end
end