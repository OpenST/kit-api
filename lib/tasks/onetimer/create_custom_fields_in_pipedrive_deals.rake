# One timer script to generate custom fields in pipedrive deal.
#
# * Author: Dhananjay
# * Date: 16/04/2019
# * Reviewed By:
#
namespace :one_timers do
  
  desc "Usage: rake RAILS_ENV=development one_timers:create_custom_fields_in_pipedrive_deals"
  
  task :create_custom_fields_in_pipedrive_deals => :environment do
  
    custom_field_for_enterprise_resp = FormIntegration::PipeDrive.new.add_custom_field_in_deals('Enterprise or Business?', ['Enterprise', 'Business'])
    
    if custom_field_for_enterprise_resp.success?
      
      if custom_field_for_enterprise_resp[:data]
        resp = custom_field_for_enterprise_resp[:data]['data']
        puts("Custom field name: #{resp['name']} => Value of \"key\" to be added in ENV vars: #{resp['key']}")
      end
    end

    custom_field_for_mobile_app_resp = FormIntegration::PipeDrive.new.add_custom_field_in_deals('Does the client have an iOS or Android app?', ['YES', 'NO'])

    if custom_field_for_mobile_app_resp.success?
      if custom_field_for_mobile_app_resp['data']
        resp = custom_field_for_mobile_app_resp[:data]['data']
        puts("Custom field name: #{resp['name']} => Value of \"key\" to be added in ENV vars: #{resp['key']}")
      end
    end
  
  end

end