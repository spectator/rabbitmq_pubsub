class Worker
  include Celluloid

  attr_reader :channel, :exchange, :queue, :num

  def initialize(connection, num)
    @channel  = connection.create_channel
    @exchange = channel.direct('test')
    @queue    = channel.queue('')
    @num      = num
  end

  def call
    queue.bind(
      exchange,
      routing_key: "worker_#{num}"
    ).subscribe(block: false, ack: true) do |info, _, payload|
      channel.ack(info.delivery_tag, _multiple = false)
      puts "Received #{deserialize(payload)} by Worker ##{num}"
    end
  end

  def deserialize(message)
    JSON.load(message)
  end
end
