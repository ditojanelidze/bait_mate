class CommentsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :set_post

  def index
    @offset = params[:offset].to_i
    @comments = @post.comments.includes(:user).offset(@offset).limit(10)
    @remaining = @post.comments_count - @offset - @comments.size

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @post }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { post: @post, comment: @comment }) }
        format.html { redirect_to @post, alert: @comment.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    if @comment.user_id == current_user.id
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post }
      end
    else
      redirect_to @post, alert: I18n.t("comments.unauthorized")
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
