# Sidekiq tips

We could use sidekiq as queuing backend for ActiveJob
https://github.com/mperham/sidekiq/wiki/Active-Job
but since it is slower and sidekiq extension is hard to use, I prefer to use
basic sidekiq (outside of ActiveJob).

To install
```
bundle add sidekiq
```
and run the main process
```
sidekiq
```

You do not need to restart the process when you make changes in jobs. Restart is
needed when you make change in sidekiq.yml configuration.

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

# Queues

Since the main process will run default queue, I prefer to name the queue based
on the app and use that name in configuration. If you run jobs from another app
you will get `NameError: uninitialized constant ...`
https://github.com/mperham/sidekiq/wiki/Advanced-Options
```
# config/sidekiq.yml
---
:concurrency: 2
:queues:
  - my_app_critical
  - my_app_default
```

In this example `my_app_default` jobs will be executed only if there is no 2
`my_app_critical` enqueued jobs. Also note if there are 2 `my_app_default`
running jobs and `my_app_critical` will have to wait them to complete.

Sidekiq supports ordered (like previos example) and weighted modes but you can
not mix those to modes. If, for example, you need a critical queue that is
processed first, and would like other queues to be weighted, you would dedicate
a Sidekiq process exclusively to the critical queue, and other Sidekiq processes
to service the rest of the queues.

```
sidekiq -q critical # Only handles jobs on the "critical" queue
sidekiq -q default -q low -q critical # Handles critical jobs only after checking for other jobs
```

# Redis

You need to install redis server, which is simply adding Heroku redis addon.
https://elements.heroku.com/addons/heroku-redis Or on AWS you can install
https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04
Since it allows only 10 connections you need to limit connections for sidekiq.

Sidekiq server uses two connections, so if `:concurrency: 3` than server uses 5
connections so you can use puma threads 5 to utilize all 10 connections.
https://github.com/mperham/sidekiq/issues/117
https://manuelvanrijn.nl/sidekiq-heroku-redis-calc/

# Web UI

https://github.com/mperham/sidekiq/wiki/Monitoring
```
# config/routes.rb
require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

# app/views/pages/index.html.erb
<%= link_to "Sidekiq", "/sidekiq" %>
```

Reset counters clear
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


# Scheduler

https://github.com/moove-it/sidekiq-scheduler

```
bundle add sidekiq-scheduler
```

Create sample scheduler
```
# app/sidekiq_worker/hello_world.rb
require 'sidekiq-scheduler'

class HelloWorld
  include Sidekiq::Worker

  def perform
    puts 'Hello world'
  end
end
```
add to configuration

```
# config/sidekiq.yml

:schedule:
  hello_world:
    cron: '0 * * * * *'   # Runs once per minute
    class: HelloWorld
```

add to routes

```
# config/routes.rb
require 'sidekiq-scheduler/web'
```
