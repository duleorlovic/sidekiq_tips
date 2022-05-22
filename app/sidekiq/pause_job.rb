class PauseJob
  include Sidekiq::Job
  sidekiq_options queue: 'my_app_default'

  def perform(*args)
    sleep 10
    puts "PauseJob finished #{args}"
  end
end
