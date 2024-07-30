# app/services/startup_notifier_service.rb
class StartupNotifierService
    def self.notify_startup
      channel_id = 'C04FT8EVBJ8' # ここに通知したいSlackチャンネルのIDを設定
    # JSTでの現在時刻を取得
    jst_time = Time.current.in_time_zone('Tokyo').strftime('%Y年%m月%d日 %H時%M分%S秒')
    # メッセージに時刻を追加
    message = ":tada:*アプリケーションのリリースが成功しました*\n>起動時間：#{jst_time}"
  
      # SlackSendMessageToChannelServiceを使用してメッセージを送信
      SlackSendMessageToChannelService.send_message_to_channel(channel_id, message)
    end
end
  