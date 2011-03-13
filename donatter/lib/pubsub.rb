# PubSub
#
# Usage:
#
# Pubsub.instance("a").subscribe do |data|
#   puts data
# end
#
# Pubsub.instance("a").publish "the data"
class PubSub
  @@instances = {}

  def self.channel(name)
    unless @@instances[name]
      @@instances[name] = self.new
    end
    @@instances[name]
  end

  def self.destroy(name)
    @@instances.delete(name)
  end


  def initialize
    @subscribers = {}
    @next_sub_id = 0
  end

  def subscribe(&block)
    @next_sub_id+=1
    @subscribers[@next_sub_id] = block
    return @next_sub_id
  end

  def unsubscribe(key)
    @subscribers.delete(key)
  end

  def publish(data)
    @subscribers.each_value do |block|
      block.call(data)
    end
  end
end
