class WebLogController < ApplicationController
    def borrow_key
        @borrow_key_query = WebLog.new(event_name: "borrow_key", user_id: current_user.id)
        @borrow_key_query.save
        channel_id = 'C0220D9QN6A' # チャンネルIDはパラメータから取得
        message = "#{current_user.profile.nickname}（#{format("%06d", current_user.id)}）が鍵を借りたよ！" # 送信するメッセージもパラメータから取得

        result = SlackSendMessageToChannelService.send_message_to_channel(channel_id, message)
        redirect_to root_path, notice: '鍵を貸し出しました！'
    end
end
