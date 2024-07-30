class CollegeController < ApplicationController

  def list
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @Colleges = College.all
  end

  def new
    @college = College.new(college_params)
    @college.save
    flash[:alert] = "作成が完了しました"
    redirect_to root_path
  end

  def generate
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def college_params #ストロングパラメータ
    params.permit(:name, :flag, :status, :created_at, :updated_at)
  end  


end
