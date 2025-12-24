class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.includes(:likes).with_attached_image
  end

  def followers
    @user = User.find(params[:id])
    @followers = @user.followers

    render partial: "users/followers_list", locals: { users: @followers }
  end

  def following
    @user = User.find(params[:id])
    @following = @user.following

    render partial: "users/following_list", locals: { users: @following }
  end
end
