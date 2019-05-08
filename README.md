# platform-api
API layer for OST Platform.

## Setup
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
For local setup remove the line ':pidfile: ./tmp/pids/sidekiq.pid' from config/sidekiq.yml
```bash
source set_env_vars.sh
sidekiq -C ./config/sidekiq.yml -q sk_api_high_task  -q sk_api_med_task -q sk_api_default
```

## Run the following steps in order to de-link a token and client.
1. Select all 'non-deployed' tokens from tokens table.
    ```mysql
    select * from tokens where status != 1; 
    ``` 
2. Set client_id for all the tokens as NULL. If you need to de-link only a particular token, please update the query accordingly.
    ```mysql
    UPDATE `tokens` SET client_id_was = client_id, client_id = NULL, debug = ('{\"disassociation_reason\":\"Token holder in openst.js v0.10.0-beta.1 had wrong callprefix for executeTransaction and executeRedemption.\"}'), updated_at='2019-03-27 00:32:03.569' WHERE (status != 1);
    ```
3. Select all workflows where workflow kind is 'tokenDeployKind'.
    ```mysql
    select * from workflows where kind = 1;
    ``` 
4. Set unique_hash as NULL. If you need to de-link only a particular token, please update the query accordingly.
    ```mysql
    update workflows set unique_hash = NULL where kind = 1;
    ```
5. For all client ids which have been been impacted we would need to unset demo economy setup related bits according to the sub env
    ```ruby
     fail if affected_client_ids.blank?
     clients = Client.where(id: affected_client_ids).all
     clients.each do |client|
       if GlobalConstant::Base.main_sub_environment?  
         client.send("unset_#{GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status}")
         client.send("unset_#{GlobalConstant::Client.mainnet_registered_in_mappy_server_status}")
       else
         client.send("unset_#{GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status}")
         client.send("unset_#{GlobalConstant::Client.sandbox_registered_in_mappy_server_status}")
       end
       client.save!
     end
    ```
    