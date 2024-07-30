require 'net/http'
require 'uri'
require 'json'

class SlackSendService
  SLACK_API_TOKEN = ENV['SLACK_API_BOT_TOKEN']

  def self.send_message_to_user(user_id, text)
    user_email = fetch_user_email(user_id)
    return unless user_email

    slack_user_id = fetch_slack_user_id(user_email)
    return 'Slack user not found' unless slack_user_id

    post_message(slack_user_id, text)
  end

  private

  def self.fetch_user_email(user_id)
    User.find_by(id: user_id)&.email
  end

  def self.fetch_slack_user_id(user_email)
    response = send_slack_api_request("users.lookupByEmail?email=#{user_email}")

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body).dig('user', 'id')
    end
  end

  def self.post_message(slack_user_id, text)
    body = { "channel" => slack_user_id, "text" => text }.to_json
    response = send_slack_api_request('chat.postMessage', 'Post', body)
    response.msg
  end

  def self.send_slack_api_request(endpoint, method = 'Get', body = nil)
    uri = URI.parse("https://slack.com/api/#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = build_http_request(uri, method, body)
    http.request(req)
  end

  def self.build_http_request(uri, method, body)
    req = if method == 'Post'
            Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
          else
            Net::HTTP::Get.new(uri)
          end

    req['Authorization'] = "Bearer #{SLACK_API_TOKEN}"
    req.body = body if body
    req
  end
end
