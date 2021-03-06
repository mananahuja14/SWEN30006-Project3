# This controller authenticates a User login
class SessionController < ApplicationController
  # Before actions to check paramters
  before_action :check_params, only: [:login]
  before_action :authenticate_user, only: [:logout]

  # Find a user with the email and email password
  # log in that user if they exist
  def login
    # Find a user with params
    user = User.authenticate(@credentials[:password], @credentials[:username])
    if user
      # Save them in the session
      log_in user
      # Redirect to posts page
      redirect_to articles_path
    else
      redirect_to :back, status: 403
    end
  end

  # Log out the user in the session and redirect to the /session/unauth
  def logout
    log_out
    redirect_to login_path
  end

  private

  def check_params
    params.require(:credentials).permit(:password, :username)
    @credentials = params[:credentials]
  end
end
