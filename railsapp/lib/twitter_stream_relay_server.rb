require 'pubsub'
require 'twitter/json_stream.rb'

class TwitterStreamRelayServer

  def initialize(track)
    @track = track
    @twitter_stream = nil
    @websocket_server = nil
  end

  def start
    EventMachine.run do 
      start_twitter_stream
      start_ws_server
    end
  end

  # Start receiving twitter stream
  def start_twitter_stream
    @twitter_stream = Twitter::JSONStream.connect(
      :path => '/1/statuses/filter.json',
      :auth => Settings.twitter_auth,
      :method => 'POST',
      :content => 'track='+URI.encode(@track.join(','))
    )
    @twitter_stream.each_item(&method(:on_stream_receive))
    @twitter_stream.on_error(&method(:on_stream_error))
    @twitter_stream.on_reconnect(&method(:on_stream_reconnect))
    @twitter_stream.on_max_reconnects(&method(:on_stream_max_reconnects))
  end

  # Upon receiving an item from Twitter Stream
  def on_stream_receive(item)
    parsed = JSON.parse(item)

    tw = Tweet.new({
      :tweet_id => parsed['id_str'],
      :text => parsed['text'],
      :twitter_id => parsed['user']['id'],
      :screen_name => parsed['user']['screen_name'],
      :profile_image_url => parsed['user']['profile_image_url'],
      :location => parsed['user']['location']
    })
    tw.save!

    # Delete old tweets
    oldest_tweet_saved = Tweet.order('created_at desc').limit(1).offset(50).first
    if oldest_tweet_saved
      Tweet.where("created_at < ?", oldest_tweet_saved.created_at).each { |tw| tw.destroy }
    end

    ::PubSub.channel("ws_server").publish tw.to_json
  end

  # Upon Twitter stream error
  def on_stream_error(message)
    puts "error: #{message}\n"
  end

  # Upon Twitter stream reconnect
  def on_stream_reconnect(timeout, retries)
    puts "reconnecting in: #{timeout} seconds\n"
  end

  # Upon Twitter stream max reconnects
  def on_stream_max_reconnects(timeout, retries)
    puts "Failed after #{retries} failed reconnects\n"
  end


  # Start WebSocket server
  def start_ws_server
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 10081) do |ws|
      ws.onopen do
        puts "WebSocket connection open"
        ::PubSub.channel("ws_server").subscribe { |data|  ws.send data }
      end

      ws.onclose do
        puts "Connection closed"
      end
    end
  end

end
