# app/controllers/request_controller.rb
class RequestController < ApplicationController
    def info

        if current_user.role_id.slice(0) == "4"
            # 管理者
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    @targetUserOld = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserNew = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: "no").order(updated_at: :desc).limit(1).first
                when "hr_ModifyUpdate"
                    @userAct = Attendance.order("id DESC").find_by(user_id: @reqUser.user_id)
                when "hr_ConectID"
                    @targetUser = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserOld = User.find_by(id: @reqValue.target)
            end
        elsif current_user.role_id.slice(2) == "5"
            # 人事部で個人情報管理権限なし
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ModifyUpdate"
                when "hr_ConectID"
                    @targetUser = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserOld = User.find_by(id: @reqValue.target)
            end
        elsif current_user.role_id.slice(2) >= "6"
            # 人事部で個人情報管理権限あり
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department, :course, {course: :college}).select("profiles.*, departments.*, courses.*, colleges.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    @targetUserOld = Profile.joins(:department, {course: :college}).select("profiles.*, departments.department, departments.position, courses.college_id, courses.name, courses.symbol, colleges.name").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserNew = Profile.joins(:department, {course: :college}).select("profiles.*, departments.department, departments.position, courses.college_id, courses.name, courses.symbol, colleges.name").where(user_id: @reqValue.target,status: "no").order(updated_at: :desc).limit(1).first
                when "hr_ModifyUpdate"
                when "hr_ConectID"
                    @targetUser = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserOld = User.find_by(id: @reqValue.target)
            end
        elsif current_user.role_id.slice(3) >= "3" || current_user.role_id.slice(4) == "1"
            # 会計部で予算管理権限あり
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ModifyUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ConectID"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
            end
            # @requests = Request.where("kind LIKE ?", "%cf%").or(Request.where("kind LIKE ?", "%gd%")).order(id: :desc)
            # @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        elsif current_user.role_id.slice(4) == "1"
            # 会計部で予算管理権限なし
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ModifyUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ConectID"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
            end
        elsif current_user.role_id.slice(5) >= "3"
            # 総務部でアカウント変更権限あり
            @reqValue = Request.where(id: params[:id]).limit(1).first
            @reqUser = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: @reqValue.user_id,status: nil).order(updated_at: :desc).limit(1).first
            case @reqValue.kind
                when "hr_UserUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ModifyUpdate"
                    flash[:alert] = "権限がありません"
                    redirect_to "/request/list"
                when "hr_ConectID"
                    @targetUser = Profile.joins(:department).select("profiles.*, departments.department, departments.position").where(user_id: @reqValue.target,status: nil).order(updated_at: :desc).limit(1).first
                    @targetUserOld = User.find_by(id: @reqValue.target)
            end


            # @requests = Request.where("kind LIKE ?", "%gd%").order(id: :desc)
            # @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        else
            flash[:alert] = "権限がありません"
            redirect_to "/request/list"
        end

    end
    def list
        if current_user.role_id.slice(0) == "4"
            @requests = Request.order(id: :desc)
            @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        elsif current_user.role_id.slice(2) >= "5"
            @requests = Request.where("kind LIKE ?", "%hr%").order(id: :desc)
            @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        elsif current_user.role_id.slice(3) >= "3" || current_user.role_id.slice(4) == "1"
            @requests = Request.where("kind LIKE ?", "%cf%").or(Request.where("kind LIKE ?", "%gd%")).order(id: :desc)
            @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        elsif current_user.role_id.slice(4) == "1"
            @requests = Request.where("kind LIKE ?", "%gd%").order(id: :desc)
            @requestsUser = Profile.joins(:department).select("profiles.*, departments.*").where(status: nil)
        else
            flash[:alert] = "権限がありません"
            redirect_to request.referer
        end
    end
    
end
