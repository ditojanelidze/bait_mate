class ProfilesController < ApplicationController
  before_action :require_login

  def show
    redirect_to user_path(current_user)
  end

  def edit
  end

  def update
    if current_user.update(profile_params)
      flash[:notice] = I18n.t("profile.update_success")
      redirect_to user_path(current_user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end
end
