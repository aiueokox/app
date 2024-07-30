class RoleController < ApplicationController

  def list
    if current_user.role_id.slice(5) < "2"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @roles = Role.joins(:department).select("roles.*, departments.*")
  end

  def assignment
    if current_user.role_id.slice(5) < "4"
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
    @grantUser = User.find(params[:id])
    @grantProfile = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @grantUser.id, status: nil).first
    if @grantUser.role_id.slice(6) == "1"
      flash[:alert] = "権限ロックがされています"
      redirect_to root_path
    end
  end

  def grant
    @grantUser = User.find(params[:id])
    @grantUser.update(role_id: params[:role_id])
    flash[:alert] = "付与が完了しました"
    redirect_to root_path
  end

  def new
    @role = Role.new(role_params)
    @role.save
    flash[:alert] = "作成が完了しました"
    redirect_to root_path
  end

  def generate
    case current_user.role_id.slice(0)
    when "4"
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def role_params #ストロングパラメータ
    params.permit(:code, :department_id, :created_at, :updated_at)
  end
  def user_params #ストロングパラメータ
    params.permit(:updated_at,:created_at,:id,:role_id)
  end  
end
