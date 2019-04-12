# Cron to set company information fetched flag in client's table..
#
# * Author: Ankit
# * Date: 09/04/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:set_company_information_flag"

  task :set_company_information_flag => :environment do

    Client.find_in_batches(batch_size: 100) do |clients_batches|

      clients_batches.each do |client|

        client.send("set_#{GlobalConstant::Client.has_company_info_property}")

        puts "Client: #{client.inspect}"
        client.save!

      end

    end

  end

end