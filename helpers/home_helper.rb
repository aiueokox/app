module HomeHelper

    def slack_send_messege_email(email,text)

        token = ENV['SLACK_API_BOT_TOKEN']

        #SlackのユーザーIDを取得
        
        request_path = "https://slack.com/api/users.lookupByEmail?email=#{email}"
        
        uri = URI.parse(request_path)
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        req = Net::HTTP::Get.new(uri.request_uri)
        req["Authorization"] = "Bearer #{token}"

        res = http.request(req)

        api_response = JSON.parse(res.body)
        slack_user_id = api_response['user']['id']
        slack_user_name = api_response['user']['name']

        #SlackのユーザーIDからメッセージを送信

        request_path = 'https://slack.com/api/chat.postMessage'
        
        uri = URI.parse(request_path)
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        req = Net::HTTP::Post.new(uri.request_uri)
        req["Content-Type"] = "application/json"
        req["Authorization"] = "Bearer #{token}"
        
        body = {
            "channel" => "#{slack_user_id}",
            "text" => "#{text}",
        }.to_json
        
        req.body = body
        res = http.request(req)

        res.msg

    end

    def slack_send_messege_userid(userID,text)

        userinfo = Profile.select("profiles.*").where(user_id: userID,status: nil,leaved_at: nil).pluck(:student_num)

        token = ENV['SLACK_API_BOT_TOKEN']

        #SlackのユーザーIDを取得
        
        request_path = "https://slack.com/api/users.lookupByEmail?email=#{userinfo[0]}@g.neec.ac.jp"
        
        uri = URI.parse(request_path)
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        req = Net::HTTP::Get.new(uri.request_uri)
        req["Authorization"] = "Bearer #{token}"

        res = http.request(req)

        api_response = JSON.parse(res.body)
        slack_user_id = api_response['user']['id']
        slack_user_name = api_response['user']['name']

        #SlackのユーザーIDからメッセージを送信

        request_path = 'https://slack.com/api/chat.postMessage'
        
        uri = URI.parse(request_path)
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        req = Net::HTTP::Post.new(uri.request_uri)
        req["Content-Type"] = "application/json"
        req["Authorization"] = "Bearer #{token}"
        
        body = {
            "channel" => "#{slack_user_id}",
            "text" => "#{text}",
        }.to_json
        
        req.body = body
        res = http.request(req)

        res.msg

    end

    def slack_send_un_touch_user
        un_touch = Attendance.where(out: nil, date: Date.current.strftime("%Y-%m-%d")).order(created_at: :desc).pluck(:user_id, :in)

        text = ":hourglass_flowing_sand:*打刻漏れ通知*\n以下、申請フォームより退出時間の打刻修正を申請してください。\n>WF：<https://action-club.jp/attendance/reqModify|*打刻時刻修正リクエストはこちらから*>\n>対象日：#{Date.current.strftime("%Y-%m-%d")}\n>※本申請は、当日のみ有効です。\n>必ず本日中に対応してください。\n"
      
        un_touch.each do |user|
          # ここでSlackSendMessageToUserServiceを使用
          SlackSendMessageToUserService.new.send_message_to_user(user, text)
        end
        logger.debug("打刻漏れ通知を送信しました。 件数：#{un_touch.count}件")
    end
    
end
