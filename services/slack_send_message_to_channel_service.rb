# app/services/slack_send_message_to_channel_service.rb
class SlackSendMessageToChannelService < SlackService
  def self.send_message_to_channel(channel_id, text)
    body = { "channel" => channel_id, "text" => text }.to_json
    send_slack_api_request('chat.postMessage', 'Post', body)
  end
end
