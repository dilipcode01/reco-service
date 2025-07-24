# require_relative '../../app/services/redis_event_consumer'

# if Rails.env.development? || Rails.env.test?
#   Thread.new { RedisEventConsumer.start }
# end 