# Sidekiq tips

We could use sidekiq as queuing backend for ActiveJob
https://github.com/mperham/sidekiq/wiki/Active-Job
but since it is slower and sidekiq extension is hard to use, I prefer to use
basic sidekiq (outside of ActiveJob).

To install
```
bundle add sidekiq
```
Let's create plain sidekiq job
```
rails g sidekiq:job pause
vi app/sidekiq/pause_job.rb
```

Sidekiq uses syntax https://github.com/mperham/sidekiq/wiki/Scheduled-Jobs
similar to ActiveJob `perform_later`
```
AJob.perform_later args
AJob.set(wait: 1.week).perform_later args
AJob.set(wait_until: Date.tomorrow.noon).perform_later args
AJob.perform_now args
```
we have

```
PauseJob.perform_async 'duke'
PauseJob.perform_in 3.hours, 'duke'
PauseJob.perform_at 3.hours.from_now, 'duke'

# for perform_now use
PauseJob.new.perform 'duke'
```

With ActiveJob you can pass entire ActiveRecord objects because GlobalID will
deserialize for us. But if you are using directly sidekiq jobs (not inherited
from ActiveJob::Base) than you should pass object_id.

# Web UI

https://github.com/mperham/sidekiq/wiki/Monitoring
```
# config/routes.rb
require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

# app/views/pages/index.html.erb
<%= link_to "Sidekiq", "/sidekiq" %>
```

Reset counters
```
# run in rails console
Sidekiq::Stats.new.reset
```

Add back to app button
```
# config/initializers/sidekiq.rb
require 'sidekiq/web'
Sidekiq::Web.app_url = '/' # show "Back to App" button
```
https://github.com/mperham/sidekiq/wiki/Best-Practices#4-use-precise-terminology
Do not use `worker` term
Job is created when you enqueue a job instance.
Process is the main sidekiq command that you started.
To see current processes and number of threads http://localhost:3000/sidekiq/busy
Busy Thread is created when proccess start executing the job

# Queues

https://github.com/mperham/sidekiq/wiki/Advanced-Options#queues
If, for example, you need a critical queue that is processed first, and would
like other queues to be weighted, you would dedicate a Sidekiq process
exclusively to the critical queue, and other Sidekiq processes to service the
rest of the queues.



# Scheduler

https://github.com/moove-it/sidekiq-scheduler
