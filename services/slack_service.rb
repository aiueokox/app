# app/services/slack_service.rb
require 'net/http'
require 'uri'
require 'json'

class SlackService
  SLACK_API_TOKEN = ENV['SLACK_API_BOT_TOKEN']

  def self.send_slack_api_request(endpoint, method = 'Get', body = nil)
    uri = URI.parse("https://slack.com/api/#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = build_http_request(uri, method, body)
    http.request(req)
  end

  private

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
