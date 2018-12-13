rails_root  = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
#rails_env   = "staging"
rails_env   = ENV['RAILS_ENV']

require "#{rails_root}/lib/global_constant/sidekiq"

queue_check_interval = 1
loc = "us"

num_workers = 1

queues = GlobalConstant::Sidekiq.queue_names.values
high_queues, med_queues, loaw_queues, others = [], [], [], []
queues.each do |_q|
  q = _q.to_s
  if q.to_s.match('st_api_high')
    high_queues << q
  elsif q.to_s.match('st_api_med')
    med_queues << q
  elsif q.to_s.match('st_api_low')
    loaw_queues << q
  else
    others << q
  end
end
final_queue_names = high_queues + med_queues + loaw_queues + others
queue_str = ""
final_queue_names.uniq.each do |q|
  queue_str += "-q #{q} "
end

num_workers.times do |num|
  God.watch do |w|

    w.name 		 = "api_sidekiq_#{rails_env}_#{loc}_#{num}"
    w.group    = "api_sidekiq"

    w.interval = 180.seconds

    w.dir = rails_root
    w.log = "/mnt/god/logs/sidekiq-api.log"
    w.pid_file = "/mnt/god/#{w.name}.pid"

    w.start = "/usr/local/rvm/wrappers/ruby-2.4.2@simple_token_api_gemset/ruby /usr/local/rvm/gems/ruby-2.4.2@simple_token_api_gemset/bin/sidekiq -d -C #{rails_root}/config/sidekiq.yml -P /mnt/god/#{w.name}.pid -e #{rails_env} -L #{rails_root}/log/sidekiq.log -r #{rails_root} #{queue_str}"
    w.stop = "/usr/local/rvm/wrappers/ruby-2.4.2@simple_token_api_gemset/ruby /usr/local/rvm/gems/ruby-2.4.2@simple_token_api_gemset/bin/sidekiqctl stop /mnt/god/#{w.name}.pid 20"

    w.uid = 'deployer'
    w.gid = 'deployer'

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
        c.notify = {:contacts => ['developers'], :priority => 1, :category => 'Kit api staging-us'}
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
        c.notify = {:contacts => ['developers'], :priority => 1, :category => 'Kit api staging-us'}
      end
    end
  end
end
