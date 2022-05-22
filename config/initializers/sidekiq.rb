require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq::Web.app_url = '/' # show "Back to App" button
