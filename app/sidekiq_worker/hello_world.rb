require 'sidekiq-scheduler'

class HelloWorld
  include Sidekiq::Worker
  sidekiq_options queue: 'my_app_default'

  def perform
    puts 'Hello world!'
  end
end
