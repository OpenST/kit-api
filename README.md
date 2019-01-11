# kit-api
API layer for handling KIT APIs.

## setup
Install all the Gems.
```
bundle install
```

Start the MySQL server.
```
mysql.server start
```

Start Memcache
```
memcached -p 11211 -d
```

Source the ENV vars.
```
source set_env_vars.sh
```

Drop existing tables and databases if any. CAUTION.
```
rake db:drop:all
```

Create all the databases.
```
rake db:create:all
```

Run all the migrations.
```
rake db:migrate
```

Start Redis
```bash
redis-server --port 6379  --requirepass 'st123'
```

Start Sidekiq
```bash
sidekiq -C ./config/sidekiq.yml -q sk_api_high_task  -q sk_api_med_task -q sk_api_default
```
