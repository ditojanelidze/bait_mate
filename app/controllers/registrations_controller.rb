class RegistrationsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if User.exists?(phone_number: @user.phone_number)
      flash.now[:alert] = I18n.t("auth.phone_already_registered")
      render :new, status: :unprocessable_entity
      return
    end

    if @user.valid?
      session[:pending_registration] = registration_params.to_h
      @user.generate_verification_code!
      @user.save(validate: false)

      SmsService.send_verification_code(@user.phone_number, @user.verification_code)

      redirect_to verify_registration_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def verify
    @phone_number = session.dig(:pending_registration, "phone_number")
    redirect_to new_registration_path unless @phone_number
  end

  def confirm
    phone_number = session.dig(:pending_registration, "phone_number")
    user = User.find_by(phone_number: phone_number)

    if user&.verification_code_valid?(params[:verification_code])
      user.clear_verification_code!
      session.delete(:pending_registration)
      session[:user_id] = user.id

      flash[:notice] = I18n.t("auth.registration_success")
      redirect_to edit_profile_path
    else
      flash[:alert] = I18n.t("auth.invalid_code")
      redirect_to verify_registration_path
    end
  end

  def resend_code
    phone_number = session.dig(:pending_registration, "phone_number")
    user = User.find_by(phone_number: phone_number)

    if user
      user.generate_verification_code!
      SmsService.send_verification_code(user.phone_number, user.verification_code)
      flash[:notice] = I18n.t("auth.code_resent")
    end

    redirect_to verify_registration_path
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :phone_number)
  end

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end
end
