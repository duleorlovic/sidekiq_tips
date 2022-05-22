class PauseJob
  include Sidekiq::Job

  def perform(*args)
    sleep 10
    puts args
  end
end
