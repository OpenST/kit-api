# Cron to create 'add_contact' and 'update_contact' events.
#
# * Author: Ankit
# * Date: 26/03/2019
# * Reviewed By:
#
desc "Usage: rake RAILS_ENV=development add_update_contact"
task :add_update_contact => :environment do

  id_array = EmailServiceApiCallHook.distinct.pluck(:receiver_entity_id)
  puts("Manager IDs: #{id_array}")

  for id in id_array

    # Create addContact entry.
    Email::HookCreator::AddContact.new({receiver_entity_id: id,receiver_entity_kind: 'manager',custom_attributes: {"platform_signup"=> 1, "platform_marketing"=> 0}}).perform
    puts("Add contact entry created for manager Id: #{id}")

    # Fetch manager.
    @manager_obj = Manager.where(id: id).first

    # If manager's email is verified, create updateContact entry.
    if @manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?")
      Email::HookCreator::UpdateContact.new({receiver_entity_id: id,receiver_entity_kind:'manager', custom_attributes: {"platform_double_optin_done"=> 1}, user_settings: {"double_opt_in_status"=> "verified"}}).perform
      puts("Update contact entry created for manager Id: #{id}")
    end

  end

end