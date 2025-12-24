class PostsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post, only: [:edit, :update, :destroy]

  def index
    @posts = Post.includes(:user, image_attachment: :blob)
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      flash[:notice] = I18n.t("posts.create_success")
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      flash[:notice] = I18n.t("posts.update_success")
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = I18n.t("posts.delete_success")
    redirect_to posts_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post
    unless @post.user_id == current_user.id
      flash[:alert] = I18n.t("posts.unauthorized")
      redirect_to posts_path
    end
  end

  def post_params
    params.require(:post).permit(:image, :description, :specie, :location, :rod, :bait)
  end
end
