class FollowsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def create
    current_user.follow(@user)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}", partial: "follows/button", locals: { user: @user }) }
      format.html { redirect_to user_path(@user) }
    end
  end

  def destroy
    current_user.unfollow(@user)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}", partial: "follows/button", locals: { user: @user }) }
      format.html { redirect_to user_path(@user) }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
