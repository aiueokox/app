# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [:new_by_user, :create_by_user]

  # 通常の新規登録アクション
  def new
    if session[:invite]
      session[:invite] = nil
    else
      redirect_to entry_join_path
    end
    @user = User.new
    @profile = @user.build_profile
  end

  # 管理者による新規ユーザー作成アクション
  def new_by_user
    unless current_user.role_id.slice(0) == "4" || current_user.role_id.slice(5) >= "4"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @user = User.new
    @profile = @user.build_profile
  end

  # 管理者による新規ユーザー作成処理
  def create_by_user
    unless current_user.role_id.slice(0) == "4" || current_user.role_id.slice(5) >= "4"
      flash[:alert] = "権限がありません"
      redirect_to request.referer and return
    end

    @user = User.new(user_params)

    # プロフィールの設定
    if @user.profile.department_id != 1
      role = Role.find_by(department_id: @user.profile.department_id)
      @user.role_id = role.code
      case @user.role_id.slice(0)
      when "3"
        @user.profile.nickname = "教職員"
      when "1"
        @user.profile.nickname = "ゲスト"
      when "4"
        @user.profile.nickname = "管理"
      end
      @user.profile.image = File.open("#{Rails.root}/app/assets/images/UserPic.png")
    end

    # ユーザーとプロフィールを保存
    if @user.save
      WebLog.create(user_id: current_user.id, event_name: "user_create", value1: @user.id)
      flash[:notice] = "ユーザーが正常に作成されました"
      redirect_to after_sign_up_path_for(@user)
    else
      flash[:alert] = "ユーザーの作成に失敗しました"
      render :new_by_user
    end
  end

  private

  # ユーザーパラメータの許可
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role_id, profile_attributes: [:username, :ruby, :last_name, :first_name, :department_id, :sex, :dob, :phone, :student_num, :course_id, :teacher_name, :commute, :parent_name, :parent_phone, :parent_address])
  end
end
