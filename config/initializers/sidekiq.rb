require "sidekiq"
require "sidekiq/cron"

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  schedule = YAML.load_file(Rails.root.join("config/sidekiq_schedule.yml"))
  Sidekiq::Cron::Job.load_from_hash(schedule)
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end