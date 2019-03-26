# Cron to create 'add_contact' and 'update_contact' events.
#
# * Author: Ankit
# * Date: 26/03/2019
# * Reviewed By:
#
desc "Usage: rake RAILS_ENV=staging add_update_contact"
task :add_update_contact => :environment do

  manager_ids = EmailServiceApiCallHook
                  .where(
                    receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind
                  )
                  .pluck(:receiver_entity_id)

  manager_ids.uniq!

  puts("Manager IDs: #{manager_ids}")

  for manager_id in manager_ids

    # Fetch manager.
    manager_obj = Manager.where(id: manager_id).first

    if manager_obj.nil?
      puts("Manager Id #{manager_id} does not exist in managers table.")
      next
    end

    sent_event_types = EmailServiceApiCallHook
                         .where(
                           receiver_entity_id: manager_id,
                           receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind
                         )
                         .pluck(:event_type)

    if sent_event_types.exclude?(GlobalConstant::EmailServiceApiCallHook.add_contact_event_type)
      # Create addContact entry.
      Email::HookCreator::AddContact.new(
        {
          receiver_entity_id: manager_id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
          custom_attributes: {"platform_signup"=> 1, "platform_marketing"=> 0}
        }).perform

      puts("Add contact entry created for manager Id: #{manager_id}")
    end

    # If manager's email is verified, create updateContact entry.
    if manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?") &&
      sent_event_types.exclude?(GlobalConstant::EmailServiceApiCallHook.update_contact_event_type)
        Email::HookCreator::UpdateContact.new(
          {
            receiver_entity_id: manager_id,
            receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
            custom_attributes: {"platform_double_optin_done"=> 1},
            user_settings: {"double_opt_in_status"=> "verified"}
          }).perform

        puts("Update contact entry created for manager Id: #{manager_id}")
    end

  end

end