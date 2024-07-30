class DepartmentController < ApplicationController
  def list
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @Departments = Department.all
  end

  def assignment
  end

  def new
    @department = Department.new(department_params)
    @department.save
    flash[:alert] = "作成が完了しました"
    redirect_to root_path
  end

  def generate
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def department_params #ストロングパラメータ
    params.permit(:department, :position, :created_at, :updated_at)
  end  

end
