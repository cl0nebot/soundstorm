# frozen_string_literal: true

if defined? Sidekiq
  common = Proc.new do |config|
    # Use a separate Redis database for the Sidekiq queue
    config.redis = {
      url: "#{Soundstorm::REDIS_URL}/2"
    }
  end

  Sidekiq.configure_server(&common)
  Sidekiq.configure_client(&common)
end
