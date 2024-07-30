# app/services/slack_send_message_to_user_service.rb
class SlackSendMessageToUserService < SlackService
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
    send_slack_api_request('chat.postMessage', 'Post', body)
  end
end
