require 'redis'
require 'json'

class RedisEventConsumer
  STREAM = 'lms_events'
  GROUP = 'reco_group'
  CONSUMER = 'reco_consumer'
  DUMMY_FIELD = 'init'

  def self.start
    redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
    # Try to create the group, using mkstream to create the stream if needed
    begin
      redis.xgroup('CREATE', STREAM, GROUP, '$', mkstream: true)
      puts "[RedisEventConsumer] Created group '#{GROUP}' on stream '#{STREAM}'"
    rescue Redis::CommandError => e
      if e.message.include?('BUSYGROUP')
        puts "[RedisEventConsumer] Group '#{GROUP}' already exists on stream '#{STREAM}'"
      elsif e.message.include?('NOGROUP') || e.message.include?('no such key')
        # Stream does not exist, add a dummy entry and retry group creation
        puts "[RedisEventConsumer] Stream '#{STREAM}' missing, adding dummy entry and retrying group creation"
        redis.xadd(STREAM, { DUMMY_FIELD => '1' })
        retry
      else
        puts "[RedisEventConsumer] Failed to create group: #{e.message}"
        raise
      end
    end
    Thread.new do
      loop do
        entries = redis.xreadgroup(GROUP, CONSUMER, { STREAM => '>' }, { count: 10, block: 5000 })
        next unless entries
        entries.each do |_, events|
          events.each do |id, data|
            # Skip the dummy entry
            next if data[DUMMY_FIELD] == '1'
            event = JSON.parse(data['data']) rescue nil
            if event && event['event_type'] == 'LessonCompletedEvent'
              # Sequent removed: event projection disabled
            end
            redis.xack(STREAM, GROUP, id)
          end
        end
      end
    end
  end
end 