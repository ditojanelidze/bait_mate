class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post

  def index
    @offset = params[:offset].to_i
    @comments = @post.comments.includes(user: { avatar_attachment: :blob }).offset(@offset).limit(10)
    @remaining = @post.comments_count - @offset - @comments.size

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  def modal
    @comments = @post.comments.includes(user: { avatar_attachment: :blob }).limit(10)
    @remaining = @post.comments_count - @comments.size

    render partial: "comments/modal_content", locals: { post: @post, comments: @comments, remaining: @remaining }
  end

  def more
    offset = params[:offset].to_i
    @comments = @post.comments.includes(user: { avatar_attachment: :blob }).offset(offset).limit(10)
    new_offset = offset + @comments.size
    remaining = @post.comments_count - new_offset

    html = render_to_string(partial: "comments/comments_list", locals: { comments: @comments })

    render json: {
      html: html,
      new_offset: new_offset,
      has_more: remaining > 0
    }
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
