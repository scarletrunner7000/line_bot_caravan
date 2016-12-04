require 'line/bot'

class WebhookController < ApplicationController

  protect_from_forgery with: :null_session # CSRF対策無効化

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      render json: {}, status: 400 and return
    end

    events = client.parse_events_from(body)
    logger.debug events.pretty_inspect

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          resp = client.reply_message(event['replyToken'], message)
          logger.debug resp
          logger.debug resp.to_hash
        end
      end
    }

    render json: {}, status: :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

end
