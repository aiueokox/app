class CourseController < ApplicationController

  def list
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
    @Courses = Course.joins(:college).select("courses.*, colleges.name AS 'c_name'")
  end

  def new
    @course = Course.new(course_params)
    @course.save
    flash[:alert] = "作成が完了しました"
    redirect_to root_path
  end

  def generate
    if current_user.role_id.slice(2) < "5"
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end

  def course_params #ストロングパラメータ
    params.permit(:college_id, :name, :year, :status, :symbol, :created_at, :updated_at)
  end  


end
