class LikesController < ApplicationController
  before_action :require_login, except: [ :likers ]
  before_action :set_post

  def likers
    @likers = @post.likes.includes(:user).map(&:user)

    render partial: "likes/likers_list", locals: { likers: @likers }
  end

  def create
    @like = @post.likes.find_or_initialize_by(user: current_user)

    respond_to do |format|
      if @like.new_record? && @like.save
        format.turbo_stream
        format.html { redirect_to @post }
      else
        format.turbo_stream { render :destroy }
        format.html { redirect_to @post }
      end
    end
  end

  def destroy
    @like = @post.likes.find_by(user: current_user)
    @like&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
