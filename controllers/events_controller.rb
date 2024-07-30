# app/controllers/events_controller.rb
class EventsController < ApplicationController

    def select_participants
        @event = Event.find(params[:id])
        @users = User.joins(profile: [:course, :department]).where(profiles: { status: nil , leaved_at: nil }).and(User.where("role_id LIKE ?", "2%"))
    end
      
    def add_participants
        @event = Event.find(params[:id])
    
        ActiveRecord::Base.transaction do
            @event.event_participants.destroy_all
            # パラメータからuser_idsを取得
            user_ids = params[:event][:user_ids]&.reject(&:blank?)
    
            # user_idsが存在する場合のみ、それに対応するevent_participantsを作成
            if user_ids
                user_ids.each do |user_id|
                    @event.event_participants.create!(user_id: user_id)
                end
            end
        end          
    
        redirect_to @event, notice: '参加者が追加されました'
    end
    

    def new
      @event = Event.new
    end
  
    def create
        @event = Event.new(event_params)
        @event.organizer_id = current_user.id # Deviseのcurrent_userメソッドを使用してログインしているユーザーのIDを取得
        if @event.save
          redirect_to select_participants_event_path(@event), notice: 'イベントが作成されました。次に参加者を選択してください。'
        else
          render :new
        end
    end

    def update
        @event = Event.find(params[:id])
        if @event.update!(event_params)
          redirect_to select_participants_event_path(@event), notice: 'イベントが更新されました。次に参加者を選択してください。'
        else
          render :edit
        end
    end
      
    # def update
    #     @event = Event.find(params[:id])
    #     ActiveRecord::Base.transaction do
    #         @event.update!(event_params)
    #         save_participants
    #     end
    #     redirect_to events_path, notice: 'イベントが更新されました'
    # rescue => e
    #     render :edit
    # end
      
  
    def index
        @events = Event.where(display_flag: true).includes(:event_participants)
        @participants_counts = @events.map { |event| event.event_participants.count }
    end
  
    def edit
      @event = Event.find(params[:id])
    end
  
    def show
      @event = Event.find(params[:id])
      @users = User.includes(profile: [:course, :department]).all
    end

    # 新規イベント申請の作成
    def new_request
      @request = Request.new  # 新しいリクエストオブジェクトの初期化
    end

    # イベント申請の保存
    def create_request
      create_service = CreateEventRequestService.new(current_user, event_request_params)
      create_service.create_request
      redirect_to root_path, notice: 'イベントの申請が完了しました。承認をお待ちください。'
    end

    # イベント申請の承認
    def approve
      unless current_user.role_id.slice(1) >= "5"
        flash[:alert] = "権限がありません"
        redirect_to request.referer
      end
      request_id = params[:id]
      approve_service = CreateEventRequestService.new(current_user, nil)
      approve_service.approve(request_id)
      redirect_to events_path, notice: 'イベントが承認され、作成されました。'
    end

    def deny
      unless current_user.role_id.slice(1) >= "5"
        flash[:alert] = "権限がありません"
        redirect_to request.referer
      end
      request_id = params[:id]
      approve_service = CreateEventRequestService.new(current_user, nil)
      approve_service.deny(request_id)
      redirect_to root_path, notice: 'イベント申請が否認されました。'
    end

    # # イベント申請の保存
    # def create_request
    #   @request = Request.new(event_request_params)
    #   @request.user_id = current_user.id # ログイン中のユーザーID
    #   @request.title = 'イベント作成リクエスト'
    #   @request.status = 'info'
    #   @request.kind = 'event_creation'

    #   if @request.save
    #     redirect_to root_path, notice: 'イベントの申請が完了しました。承認をお待ちください。'
    #   else
    #     render :new_request
    #   end
    # end

    # # イベント申請の承認
    # def approve
    #   @request = Request.find(params[:id])
    #   if @request.update(status: 'success')
    #     Event.create!(
    #       title: @request.event_title,
    #       description: @request.event_description,
    #       start_date_time: @request.event_start_date_time,
    #       end_date_time: @request.event_end_date_time,
    #       organizer_id: @request.user_id, # 申請者のユーザーID
    #       display_flag: 1  # デフォルトで1を設定
    #     )
    #     redirect_to events_path, notice: 'イベントが承認され、作成されました。'
    #   else
    #     redirect_to root_path, alert: 'イベントの承認に失敗しました。'
    #   end
    # end

    # def deny
    #   @request = Request.find(params[:id])
  
    #   if @request.update(status: 'danger')
    #     redirect_to root_path, notice: 'イベント申請が否認されました。'
    #   else
    #     redirect_to root_path, alert: 'イベント申請の否認に失敗しました。'
    #   end
    # end
  
    private

    def event_request_params
      params.require(:request).permit(:event_title, :event_description, :event_start_date_time, :event_end_date_time, :event_announcement_date)
    end

    def event_params
        params.require(:event).permit(:title, :description, :start_date_time, :end_date_time, :organizer_id, :display_flag, :announcement_date)
    end
    
    def save_participants
        @event.event_participants.destroy_all
        user_ids = params[:event][:user_ids]&.reject(&:blank?)
        user_ids.each do |user_id|
            @event.event_participants.create(user_id: user_id)
        end
    end
    
      
end
