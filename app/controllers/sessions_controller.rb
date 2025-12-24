class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(phone_number: params[:phone_number])

    if user
      user.generate_verification_code!
      SmsService.send_verification_code(user.phone_number, user.verification_code)
      session[:login_phone] = user.phone_number

      redirect_to verify_session_path
    else
      flash.now[:alert] = I18n.t("auth.phone_not_found")
      render :new, status: :unprocessable_entity
    end
  end

  def verify
    @phone_number = session[:login_phone]
    redirect_to new_session_path unless @phone_number
  end

  def confirm
    user = User.find_by(phone_number: session[:login_phone])

    if user&.verification_code_valid?(params[:verification_code])
      user.clear_verification_code!
      session.delete(:login_phone)
      session[:user_id] = user.id

      redirect_to root_path
    else
      flash[:alert] = I18n.t("auth.invalid_code")
      redirect_to verify_session_path
    end
  end

  def resend_code
    user = User.find_by(phone_number: session[:login_phone])

    if user
      user.generate_verification_code!
      SmsService.send_verification_code(user.phone_number, user.verification_code)
      flash[:notice] = I18n.t("auth.code_resent")
    end

    redirect_to verify_session_path
  end

  def destroy
    session[:user_id] = nil

    redirect_to new_session_path
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end
end
