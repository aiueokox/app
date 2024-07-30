class ExceptionNotificationMiddleware
    def initialize(app)
      @app = app
    end
  
    def call(env)
      begin
        @app.call(env)
      rescue => e
        notify_slack(e, env)
        raise e
      end
    end
  
    private
  
    def notify_slack(exception, env)
      user_id = env['warden']&.user&.id || 'アカウント不明'
      request = ActionDispatch::Request.new(env)
      path = request.path
      source_code = extract_source_code(exception)
  
      text = <<~TEXT
        :construction:*エラーが発生しました*
        - ユーザーID: #{user_id}
        - エラー内容: #{exception.message}
        - 発生箇所: #{exception.backtrace.first}
        - 発生パス: #{path}
        - 周辺ソースコード:
        ```
        #{source_code}
        ```
      TEXT
  
      SlackSendMessageToChannelService.send_message_to_channel('C04FT8EVBJ8', text)
    end
  
    def extract_source_code(exception)
      file, line = exception.backtrace.first.split(":")
      return "ソースコードを取得できませんでした: #{file}" unless File.exist?(file)
      
      lines = File.readlines(file)
      start_line = [line.to_i - 5, 0].max
      end_line = [line.to_i + 5, lines.size].min
  
      lines[start_line..end_line].join
    end
  end
  