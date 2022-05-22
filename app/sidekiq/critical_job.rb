class CriticalJob
  include Sidekiq::Job
  sidekiq_options queue: 'my_app_critical'

  def perform(*args)
    sleep 10
    puts "CriticalJob finished #{args}"
  end
end
