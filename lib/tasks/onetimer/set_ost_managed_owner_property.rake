# Cron to set has enabled metamask property for existing tokens.
#
# * Author: Ankit
# * Date: 17/04/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:set_ost_managed_owner_property"

  task :set_ost_managed_owner_property => :environment do

    Token.where(properties: nil).find_in_batches(batch_size: 100) do |token_batches|

      token_batches.each do |token|

        token.send("unset_#{GlobalConstant::ClientToken.has_ost_managed_owner}")

        puts "Token: #{token.inspect}"
        token.save!

      end

    end

  end

end