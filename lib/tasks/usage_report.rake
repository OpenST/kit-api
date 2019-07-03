desc "Usage: rake RAILS_ENV=development usage_report"

task :usage_report => :environment do

  require 'csv'
  require 'uri'

  client_details = {}
  lifetime_data_by_email = {}
  emails_registered_today = []

  current_ts = Time.now.to_i
  day_start_ts = current_ts - 24.hours.to_i

  lifetime_summary_report = {
    registrations: 0,
    double_opt_in: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0,
    resolved_ts_errors: 0,
    resolved_snm_errors: 0,
    ts_errors: 0,
    snm_errors: 0,
    wallet_setup: 0
  }

  daily_summary_report = {
    registrations: 0,
    double_opt_in: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0,
    resolved_ts_errors: 0,
    resolved_snm_errors: 0,
    ts_errors: 0,
    snm_errors: 0,
    wallet_setup: 0
  }

  popcorn_economy = ENV['OST_POPCORN_ECONOMY'].to_i

  token_stats = {
      new_popcorn_account_activations: 0,
      lifetime_popcorn_account_activations: 0,
      new_popcorn_first_transactions: 0,
      lifetime_popcorn_first_transactions: 0,
      new_platform_account_activations: 0,
      lifetime_platform_account_activations: 0,
      new_platform_first_transactions: 0,
      lifetime_platform_first_transactions: 0,
      lifetime_total_transfers: 0,
      lifetime_popcorn_total_transfers: 0
  }

  if popcorn_economy > 0
    popcorn_client = ENV['OST_POPCORN_ECONOMY_CLIENT'].to_i
    params_for_saas_api = {
        token_id: popcorn_economy,
        client_id: popcorn_client,
    }

    r = SaasApi::Dashboard::Get.new.perform(params_for_saas_api)
    return r unless r.success?
    token_stats[:lifetime_popcorn_total_transfers] = r.data['totalTokenTransfers']
  end

  all_manager_rows = []
  first_active_superadmin_manager_map = {}
  first_active_superadmin_details = []

  # Fetch all active managers in batches.
  Manager.find_in_batches(batch_size: 100) do |managers_batches|

    batched_manager_ids = []

    managers_batches.each do |row|

      split_email = row.email.to_s.split('@')

      if split_email[1] === 'ost.com'
        next
      end

      all_manager_rows << row
      batched_manager_ids << row.id

    end

    if batched_manager_ids.present?
      # Fetch all client managers in batches.
      ClientManager.where(manager_id: batched_manager_ids).each do |client_manager_row|

        client_details[client_manager_row.client_id] = client_details[client_manager_row.client_id] || {
          processed: 0,
          registered_super_admins: 0,
          invited_super_admins: 0,
          registered_admins: 0,
          invited_admins: 0,
          company_name: '',
          enterprise: '',
          mobile_app: '',
          webhook_setup: 'NO'
        }

        client_manager_entity = client_manager_row.formatted_cache_data

        if client_manager_entity[:privileges].exclude?(GlobalConstant::ClientManager.has_been_deleted_privilege)

          if client_manager_entity[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_privilege)
            client_details[client_manager_row.client_id][:registered_super_admins] += 1

          elsif client_manager_entity[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_invited_privilege)
            client_details[client_manager_row.client_id][:invited_super_admins] += 1

          elsif client_manager_entity[:privileges].include?(GlobalConstant::ClientManager.is_admin_privilege)
            client_details[client_manager_row.client_id][:registered_admins] += 1

          elsif client_manager_entity[:privileges].include?(GlobalConstant::ClientManager.is_admin_invited_privilege)
            client_details[client_manager_row.client_id][:invited_admins] += 1
          end

        end

        if Util::CommonValidator.is_active_super_admin?(client_manager_entity[:privileges]) &&
          client_details[client_manager_row.client_id][:processed] == 0

          client_details[client_manager_row.client_id][:processed] = 1
          first_active_superadmin_manager_map[client_manager_row.manager_id] = 1
        end

      end

    end

  end

  # Create final array of required managers.
  all_manager_rows.each do |row|
    if first_active_superadmin_manager_map[row.id]
      first_active_superadmin_details << row
    end
  end

  client_ids = []

  first_active_superadmin_details.each do |row|

    lifetime_data_by_email[row.email] = {
      client_id: 0,
      first_name: '',
      last_name: '',
      is_verified_email: 0,
      registered_at: nil,
      stake_and_mint_done: 0,
      made_transactions: 0,
      token_deployment_status: GlobalConstant::ClientToken.not_deployed,
      token_symbol: ''
    }

    client_id = row.current_client_id

    registered_today = row.created_at.to_i > day_start_ts

    if registered_today
      emails_registered_today << row.email
    end

    client_ids << client_id
    lifetime_summary_report[:registrations] += 1
    if registered_today
      daily_summary_report[:registrations] += 1
    end

    lifetime_data_by_email[row.email][:client_id] = client_id
    lifetime_data_by_email[row.email][:first_name] = row.first_name
    lifetime_data_by_email[row.email][:last_name] = row.last_name
    lifetime_data_by_email[row.email][:registered_at] = row.created_at

    if row.send("#{GlobalConstant::Manager.has_verified_email_property}?")
      lifetime_data_by_email[row.email][:is_verified_email] = 1
      lifetime_summary_report[:double_opt_in] += 1
      if registered_today
        daily_summary_report[:double_opt_in] += 1
      end
    else
      lifetime_data_by_email[row.email][:is_verified_email] = 0
    end
    
    dashboard_service_response = DashboardManagement::Get.new({
                                                                client_id: client_id,
                                                                manager: row.formatted_cache_data
                                                              }).perform
    
    if dashboard_service_response.success?
      if dashboard_service_response.data[:token]
        lifetime_data_by_email[row.email][:token_id] = dashboard_service_response.data[:token][:id]
        lifetime_data_by_email[row.email][:token_deployment_status] = dashboard_service_response.data[:token][:status]
        lifetime_data_by_email[row.email][:token_symbol] = dashboard_service_response.data[:token][:symbol]
        lifetime_data_by_email[row.email][:token_name] = dashboard_service_response.data[:token][:name]
        lifetime_data_by_email[row.email][:base_token] = dashboard_service_response.data[:token][:stake_currency_symbol]
        lifetime_data_by_email[row.email][:managed_by] = (dashboard_service_response.data[:token][:properties].
            include?(GlobalConstant::ClientToken.has_ost_managed_owner) ? "Managed": "Metamask")
        if lifetime_data_by_email[row.email][:token_deployment_status] == 'deploymentCompleted'
          lifetime_summary_report[:token_setup] += 1
          if registered_today
            daily_summary_report[:token_setup] += 1
          end
        end
        if dashboard_service_response.data[:token][:id].to_i != popcorn_economy
          token_stats[:lifetime_total_transfers] += dashboard_service_response.data[:dashboard_details][:total_transfers].to_i
        end
      end

      if dashboard_service_response.data[:dashboard_details][:total_supply].to_f > 0
        lifetime_data_by_email[row.email][:stake_and_mint_done] = 1
        lifetime_summary_report[:stake_and_mint] += 1
        if registered_today
          daily_summary_report[:stake_and_mint] += 1
        end
      end

      if dashboard_service_response.data[:dashboard_details][:circulating_supply].to_f > 0
        lifetime_data_by_email[row.email][:made_transactions] = 1
        lifetime_summary_report[:transactions] += 1
        if registered_today
          daily_summary_report[:transactions] += 1
        end
      end
    end

  end

  all_workflows = Workflow.where(kind: [GlobalConstant::Workflow.token_deploy, GlobalConstant::Workflow.bt_stake_and_mint])
                      .where(client_id: client_ids).all
  all_failed_workflows = []
  client_workflow_dates = {}
  all_workflows.each do |wf|
    all_failed_workflows << wf if [GlobalConstant::Workflow.failed, GlobalConstant::Workflow.completely_failed].include?(wf.status)
    client_workflow_dates[wf.client_id] ||= {token_deploy: nil, stake_mint: nil}
    if wf.kind == GlobalConstant::Workflow.token_deploy
      client_workflow_dates[wf.client_id][:token_deploy] = wf.created_at
    end
    if wf.kind == GlobalConstant::Workflow.bt_stake_and_mint
      client_workflow_dates[wf.client_id][:stake_mint] = wf.created_at
    end
  end

  clientwise_lifetime_errors = {}
  clientwise_daily_errors = {}

  total_lifetime_errors = {snm: 0, ts: 0}
  total_daily_errors = {snm: 0, ts: 0}

  all_failed_workflows.each do |row|
    client_id = row.client_id

    is_daily_error = row.created_at.to_i > day_start_ts

    clientwise_lifetime_errors[client_id] ||= {snm: 0, ts: 0}
    if is_daily_error
      clientwise_daily_errors[client_id] ||= {snm: 0, ts: 0}
    end

    if row.kind == GlobalConstant::Workflow.token_deploy
      clientwise_lifetime_errors[client_id][:ts] += 1
      total_lifetime_errors[:ts] += 1

      if is_daily_error
        clientwise_daily_errors[client_id][:ts] += 1
        total_daily_errors[:ts] += 1
      end
    else
      clientwise_lifetime_errors[client_id][:snm] += 1
      total_lifetime_errors[:snm] += 1

      if is_daily_error
        clientwise_daily_errors[client_id][:snm] += 1
        total_daily_errors[:snm] += 1
      end
    end
  end

  lifetime_summary_report[:ts_errors] = total_lifetime_errors[:ts]
  lifetime_summary_report[:snm_errors] = total_lifetime_errors[:snm]
  daily_summary_report[:ts_errors] = total_daily_errors[:ts]
  daily_summary_report[:snm_errors] = total_daily_errors[:snm]

  all_resolved_workflow_ids = WorkflowStep.where('status is NULL').pluck(:workflow_id).uniq
  all_resolved_workflows = Workflow.where(id: all_resolved_workflow_ids,
                                          kind: [GlobalConstant::Workflow.token_deploy, GlobalConstant::Workflow.bt_stake_and_mint])
                             .where(client_id: client_ids).where(status: GlobalConstant::Workflow.completed).all

  clientwise_lifetime_resolved_errors = {}

  total_lifetime_resolved_errors = {snm: 0, ts: 0}

  all_resolved_workflows.each do |row|
    client_id = row.client_id

    clientwise_lifetime_resolved_errors[client_id] ||= {snm: 0, ts: 0}

    if row.kind == GlobalConstant::Workflow.token_deploy
      clientwise_lifetime_resolved_errors[client_id][:ts] += 1
      total_lifetime_resolved_errors[:ts] += 1
    else
      clientwise_lifetime_resolved_errors[client_id][:snm] += 1
      total_lifetime_resolved_errors[:snm] += 1
    end
  end


  lifetime_summary_report[:resolved_ts_errors] = total_lifetime_resolved_errors[:ts]
  lifetime_summary_report[:resolved_snm_errors] = total_lifetime_resolved_errors[:snm]


  def generate_and_upload_csv(data_by_email, clientwise_errors, clientwise_resolved_errors, report_type, clientwise_details, client_workflow_dates)
    csv_data = []

    # prepare CSV Data

    # append headers
    if GlobalConstant::Base.main_sub_environment?
      csv_data.push([
                        'Company Name',
                        'First super admin email',
                        'First super admin first name',
                        'First super admin last name',
                        'Token deploy status',
                        'Token name',
                        'Token symbol',
                        'What was staked?',
                        'Stake and mint done',
                        'Error in step',
                        'Error solved',
                        'Performed First transaction',
                        'Has setup Webhooks?'
                    ])
    else
      csv_data.push([
                        'Company Name',
                        'Enterprise',
                        'Has mobile app',
                        'First super admin email',
                        'First super admin first name',
                        'First super admin last name',
                        'Registered at',
                        'Double opt in done',
                        'Token deploy status',
                        'Token name',
                        'Token symbol',
                        'What was staked?',
                        'Stake and mint done',
                        'Error in step',
                        'Error solved',
                        'Performed First transaction',
                        'Metamask or Managed?',
                        'Invited super admins',
                        'Registered super admins',
                        'Invited admins',
                        'Registered admins',
                        'Connected to OST Wallet app',
                        'Sent Wallet invites?',
                        'Has setup Webhooks?'
                    ])
    end

    email_invites = TestEconomyInvite.all.index_by(&:token_id)

    data_by_email.each do |email, data|
      error_in_step = ''
      error_solved = ''

      if data[:client_id] > 0
        e = clientwise_errors[data[:client_id]] || {snm: 0, ts: 0}
        re = clientwise_resolved_errors[data[:client_id]] || {snm: 0, ts: 0}

        if (e[:snm] + re[:snm]) > 0
          error_in_step = 'stake and mint'
          error_solved = e[:snm] == 0 ? 'YES' : 'NO'
        elsif (e[:ts] + re[:ts]) > 0
          error_in_step = 'token setup'
          error_solved = e[:ts] == 0 ? 'YES' : 'NO'
        end
      end

      client_id = data[:client_id]

      buffer = []

      buffer.push(clientwise_details[client_id][:company_name])
      if GlobalConstant::Base.sandbox_sub_environment?
        buffer.push(clientwise_details[client_id][:enterprise])
        buffer.push(clientwise_details[client_id][:mobile_app])
      end
      buffer.push(email)
      buffer.push(data[:first_name])
      buffer.push(data[:last_name])
      if GlobalConstant::Base.sandbox_sub_environment?
        buffer.push(data[:registered_at])
        buffer.push(data[:is_verified_email] == 1 ? 'YES' : 'NO')
      end
      buffer.push((client_workflow_dates[client_id].present? &&
          client_workflow_dates[client_id][:token_deploy].present?) ? client_workflow_dates[client_id][:token_deploy] : '')
      buffer.push(data[:token_name])
      buffer.push(data[:token_symbol])
      buffer.push(data[:base_token])
      buffer.push((data[:stake_and_mint_done] == 1 && client_workflow_dates[client_id].present? &&
          client_workflow_dates[client_id][:stake_mint].present?) ? client_workflow_dates[client_id][:stake_mint] : '')
      buffer.push(error_in_step)
      buffer.push(error_solved)
      buffer.push(data[:made_transactions] == 1 ? 'YES' : 'NO')
      if GlobalConstant::Base.sandbox_sub_environment?
        buffer.push(data[:managed_by])
        buffer.push(clientwise_details[client_id][:invited_super_admins])
        buffer.push(clientwise_details[client_id][:registered_super_admins])
        buffer.push(clientwise_details[client_id][:invited_admins])
        buffer.push(clientwise_details[client_id][:registered_admins])
        buffer.push(clientwise_details[client_id][:wallet_setup])
        buffer.push(email_invites[data[:token_id]].present? ? 'YES' : 'NO')
      end
      buffer.push(clientwise_details[client_id][:webhook_setup])

      csv_data.push(buffer)
    end

    puts "Data generated for report type: " + report_type

    file_name = "#{report_type}_#{Time.now.to_i}.csv"

    # write data to csv file
    File.open(file_name, "w") {|f| f.write(csv_data.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}

    puts "Data written to local file: " + report_type

    s3_manager = Aws::S3Manager.new(GlobalConstant::S3.private_access)

    # upload file to S3
    result = s3_manager.upload(
      "#{GlobalConstant::S3.platform_usage_reports_folder}/#{file_name}",
      File.open(file_name),
      GlobalConstant::S3.reports_bucket,
      {
        content_type: 'text/csv',
        expires: Time.now + 7.day,
      }
    )
    unless result.success?
      Rails.logger.error('upload file error for report type: ' + report_type +
                           "\n" + result.to_json)
      return result
    end

    puts "Data uploaded to S3. response #{result.to_json}"

    # Generate pre-signed URL.
    result = s3_manager.get_signed_url_for(
      GlobalConstant::S3.reports_bucket,
      "#{GlobalConstant::S3.platform_usage_reports_folder}/#{file_name}",
      {
        expires_in: 24 * 60 * 60 #24 hours in seconds
      }
    )
    unless result.success?
      Rails.logger.error('generate_pre_signed_url_error for report type: ' + report_type +
                           "\n" + result.to_json)
    end

    result.data[:file_name] = file_name

    return result
  end

  # Fetch client details.
  Client.where(id: client_ids).find_in_batches(batch_size: 100) do |client_batches|

    # Fetch all webhooks of client
    client_webhooks = WebhookSubscription.where(client_id: client_batches.map{|x|x.id}).index_by(&:client_id)

    client_batches.each do |row|
      client_entity = row.formatted_cache_data

      if client_entity[:company_name]
        client_details[client_entity[:id]][:company_name] = client_entity[:company_name]
        if client_entity[:properties].include?(GlobalConstant::Client.has_one_million_users_property)
          client_details[client_entity[:id]][:enterprise] = 'YES'
        else
          client_details[client_entity[:id]][:enterprise] = 'NO'
        end
        if client_entity[:properties].include?(GlobalConstant::Client.has_mobile_app_property)
          client_details[client_entity[:id]][:mobile_app] = 'YES'
        else
          client_details[client_entity[:id]][:mobile_app] = 'NO'
        end
        if client_entity[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)
          client_details[client_entity[:id]][:wallet_setup] = 'YES'
          lifetime_summary_report[:wallet_setup] += 1
          if client_entity[:created_at] > day_start_ts
            daily_summary_report[:wallet_setup] += 1
          end
        else
          client_details[client_entity[:id]][:wallet_setup] = 'NO'
        end
        if client_webhooks[client_entity[:id]].present?
          client_details[client_entity[:id]][:webhook_setup] = 'YES'
        end
      end
    end

  end

  lifetime_upload_response = generate_and_upload_csv(lifetime_data_by_email, clientwise_lifetime_errors,
                                                     clientwise_lifetime_resolved_errors, 'lifetime',
                                                     client_details, client_workflow_dates)
  return lifetime_upload_response unless lifetime_upload_response.success?

  daily_data_by_email = {}
  emails_registered_today.each do |email|
    daily_data_by_email[email] = lifetime_data_by_email[email]
  end

  daily_upload_response = generate_and_upload_csv(daily_data_by_email, clientwise_lifetime_errors,
                                                  clientwise_lifetime_resolved_errors, 'daily',
                                                  client_details, client_workflow_dates)
  return daily_upload_response unless daily_upload_response.success?

  puts("Lifetime secured URL : #{lifetime_upload_response.data[:presigned_url]}")
  puts("Lifetime summary data : #{lifetime_summary_report.inspect}")

  puts("Daily secured URL : #{daily_upload_response.data[:presigned_url]}")
  puts("Daily summary data : #{daily_summary_report.inspect}")



  # delete local file
  File.delete(lifetime_upload_response.data[:file_name]) if File.exist?(lifetime_upload_response.data[:file_name])
  File.delete(daily_upload_response.data[:file_name]) if File.exist?(daily_upload_response.data[:file_name])

  r = DemoMappyServerApi.new.send_request_of_type(
      'get',
      'token-stats',
      {
          api_endpoint: GlobalConstant::SaasApi.api_endpoint_for_current_version,
          stats_post_ts: day_start_ts
      }
  )

  if r.success?
    stats_from_mappy = r.data
    stats_from_mappy[:lifetime_user_activated_records].each do |tid, count|
      if tid.to_i == popcorn_economy
        token_stats[:lifetime_popcorn_account_activations] = count
      else
        token_stats[:lifetime_platform_account_activations] += count
      end
    end
    stats_from_mappy[:user_activated_records_post_ts].each do |tid, count|
      if tid.to_i == popcorn_economy
        token_stats[:new_popcorn_account_activations] = count
      else
        token_stats[:new_platform_account_activations] += count
      end
    end
    stats_from_mappy[:lifetime_trx_records].each do |tid, count|
      if tid.to_i == popcorn_economy
        token_stats[:lifetime_popcorn_first_transactions] = count
      else
        token_stats[:lifetime_platform_first_transactions] += count
      end
    end
    stats_from_mappy[:trx_records_post_ts].each do |tid, count|
      if tid.to_i == popcorn_economy
        token_stats[:new_popcorn_first_transactions] = count
      else
        token_stats[:new_platform_first_transactions] += count
      end
    end
  end


  template_name = GlobalConstant::PepoCampaigns.platform_usage_report_template
  template_vars = {
    daily_registrations: daily_summary_report[:registrations],
    daily_email_verifications: daily_summary_report[:double_opt_in],
    daily_token_setup: daily_summary_report[:token_setup],
    daily_client_stake_mint: daily_summary_report[:stake_and_mint],
    daily_client_atleast_one_transaction: daily_summary_report[:transactions],
    daily_client_setup_wallet: daily_summary_report[:wallet_setup],

    lifetime_registrations: lifetime_summary_report[:registrations],
    lifetime_email_verifications: lifetime_summary_report[:double_opt_in],
    lifetime_token_setup: lifetime_summary_report[:token_setup],
    lifetime_client_stake_mint: lifetime_summary_report[:stake_and_mint],
    lifetime_client_atleast_one_transaction: lifetime_summary_report[:transactions],
    lifetime_client_setup_wallet: lifetime_summary_report[:wallet_setup],

    unresolved_token_setup_errors: lifetime_summary_report[:ts_errors],
    unresolved_stake_mint_errors: lifetime_summary_report[:snm_errors],
    resolved_token_setup_errors: lifetime_summary_report[:resolved_ts_errors],
    resolved_stake_mint_errors: lifetime_summary_report[:resolved_snm_errors],
    date: Time.now.strftime("%Y-%m-%d"),

    daily_report_link: CGI.escape(daily_upload_response.data[:presigned_url]),
    lifetime_report_link: CGI.escape(lifetime_upload_response.data[:presigned_url])
  }

  template_vars.merge!(token_stats)

  recipient_emails = GlobalConstant::UsageReportRecipient.email_ids

  recipient_emails.each do |email|
    puts("Sending email to: " + email)

    send_mail_response = Email::Services::PepoCampaigns.new.send_transactional_email(
      email,
      template_name,
      template_vars
    )

    if send_mail_response['error'].present?
      puts("Error in sending email:" + send_mail_response['error'])
      return
    end
  end
end