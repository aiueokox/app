class EventParticipantsController < ApplicationController
    def update_attendance
        participant = EventParticipant.find_by(user_id: params[:user_id], event_id: params[:event_id])
        
        if participant && participant.unattended?
          participant.attended!
          render json: { success: true, message: '出席ステータスを変更しました。' }
        else
          render json: { success: false, message: '出席ステータスの変更に失敗しました。' }, status: 400
        end
    end

    def result
        if params[:user_id].blank?
          redirect_to root_path, alert: 'ユーザーIDが指定されていません。'
          return
        end
        
        @resultUser = User.includes(profile: [:course, :department]).find_by(id: params[:user_id])
        
        unless @resultUser
          redirect_to root_path, alert: '指定されたユーザーが見つかりませんでした。'
        end
    end
      
end
