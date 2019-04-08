desc "Usage: rake RAILS_ENV=production usage_report"

task :usage_report => :environment do

  require 'csv'
  require 'uri'

  lifetime_data_by_email = {}
  emails_registerred_today = []

  current_ts = Time.now.to_i
  day_start_ts = current_ts - 24.hours.to_i

  lifetime_summary_report = {
    registrations: 0,
    double_opt_in: 0,
    is_mfa_setup: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0,
    resolved_ts_errors: 0,
    resolved_snm_errors: 0,
    ts_errors: 0,
    snm_errors: 0
  }

  daily_summary_report = {
    registrations: 0,
    double_opt_in: 0,
    is_mfa_setup: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0,
    resolved_ts_errors: 0,
    resolved_snm_errors: 0,
    ts_errors: 0,
    snm_errors: 0
  }

  manager_rows = Manager.where(
    status: GlobalConstant::Manager.active_status).all

  client_ids = []

  manager_rows.each do |row|

    split_email = row.email.to_s.split('@')

    if split_email[1] === 'ost.com'
      next
    end

    lifetime_data_by_email[row.email] = {
      whitelisted_at: row.created_at,
      client_id: 0,
      is_verified_email: 0,
      is_mfa_setup: 0,
      registered_at: nil,
      stake_and_mint_done: 0,
      made_transactions: 0,
      token_deployment_status: GlobalConstant::ClientToken.not_deployed,
      token_symbol: ''
    }

    client_id = row.current_client_id

    registered_today = row.created_at.to_i > day_start_ts

    if registered_today
      emails_registerred_today << row.email
    end

    client_ids << client_id
    lifetime_summary_report[:registrations] += 1
    if registered_today
      daily_summary_report[:registrations] += 1
    end

    lifetime_data_by_email[row.email][:client_id] = client_id
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

    if row.send("#{GlobalConstant::Manager.has_setup_mfa_property}?")
      lifetime_data_by_email[row.email][:is_mfa_setup] = 1
      lifetime_summary_report[:is_mfa_setup] += 1
      if registered_today
        daily_summary_report[:is_mfa_setup] += 1
      end
    else
      lifetime_data_by_email[row.email][:is_mfa_setup] = 0
    end

    dashboard_service_response = DashboardManagement::Get.new({client_id: client_id}).perform

    if dashboard_service_response.success?
      if dashboard_service_response.data[:token]
        lifetime_data_by_email[row.email][:token_deployment_status] = dashboard_service_response.data[:token][:status]
        lifetime_data_by_email[row.email][:token_symbol] = dashboard_service_response.data[:token][:symbol]
        if lifetime_data_by_email[row.email][:token_deployment_status] == 'deploymentCompleted'
          lifetime_summary_report[:token_setup] += 1
          if registered_today
            daily_summary_report[:token_setup] += 1
          end
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


  all_failed_workflows = Workflow.where(kind: [GlobalConstant::Workflow.token_deploy, GlobalConstant::Workflow.bt_stake_and_mint])
                    .where(client_id: client_ids)
                    .where(status: [GlobalConstant::Workflow.failed, GlobalConstant::Workflow.completely_failed]).all

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


  def generate_and_upload_csv(data_by_email, clientwise_errors, clientwise_resolved_errors, report_type)
    csv_data = []

    # prepare CSV Data

    # append headers
    csv_data.push([
                             'email',
                             'whitelisted_at',
                             'registered_at',
                             'double opt in done',
                             'mfa setup',
                             'token deploy status',
                             'token symbol',
                             'stake and mint done',
                             'error in step',
                             'error solved',
                             'performed transactions'
                           ])

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

      buffer = []
      buffer.push(email)
      buffer.push(data[:whitelisted_at])
      buffer.push(data[:registered_at])
      buffer.push(data[:is_verified_email] == 1 ? 'YES' : 'NO')
      buffer.push(data[:is_mfa_setup] == 1 ? 'YES' : 'NO')
      buffer.push(data[:token_deployment_status])
      buffer.push(data[:token_symbol])
      buffer.push(data[:stake_and_mint_done] == 1 ? 'YES' : 'NO')
      buffer.push(error_in_step)
      buffer.push(error_solved)
      buffer.push(data[:made_transactions] == 1 ? 'YES' : 'NO')
      csv_data.push(buffer)
    end

    puts "Data generated for report type: " + report_type

    file_name = "#{report_type}_#{Time.now.to_i}.csv"

    # write data to csv file
    File.open(file_name, "w") {|f| f.write(csv_data.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}

    puts "Data written to local file: " + report_type

    s3_manager = Aws::S3Manager.new

    # upload file to S3
    r = s3_manager.upload(
      "#{GlobalConstant::S3.platform_usage_reports_folder}/#{file_name}",
      File.open(file_name),
      GlobalConstant::S3.reports_bucket,
      {
        content_type: 'text/csv',
        expires: Time.now + 7.day,
      }
    )
    unless r.success?
      Rails.logger.error('upload file error for report type: ' + report_type +
                           "\n" + r.to_json)
      return r
    end

    puts "Data uploaded to S3. response #{r.to_json}"

    # generate presigned URL
    r = s3_manager.get_signed_url_for(
      GlobalConstant::S3.reports_bucket,
      "#{GlobalConstant::S3.platform_usage_reports_folder}/#{file_name}",
      {
        expires_in: 24 * 60 * 60 #24 hours in seconds
      }
    )
    unless r.success?
      Rails.logger.error('generate_pre_signed_url_error for report type: ' + report_type +
                           "\n" + r.to_json)
    end

    r.data[:file_name] = file_name

    return r
  end

  lifetime_upload_reposnse = generate_and_upload_csv(lifetime_data_by_email, clientwise_lifetime_errors, clientwise_lifetime_resolved_errors, 'lifetime')
  return lifetime_upload_reposnse unless lifetime_upload_reposnse.success?

  daily_data_by_email = {}
  emails_registerred_today.each do |email|
    daily_data_by_email[email] = lifetime_data_by_email[email]
  end

  daily_upload_reposnse = generate_and_upload_csv(daily_data_by_email, clientwise_lifetime_errors, clientwise_lifetime_resolved_errors, 'daily')
  return daily_upload_reposnse unless daily_upload_reposnse.success?

  puts("Lifetime secured URL : #{lifetime_upload_reposnse.data[:presigned_url]}")
  puts("Lifetime summary data : #{lifetime_summary_report.inspect}")

  puts("Daily secured URL : #{daily_upload_reposnse.data[:presigned_url]}")
  puts("Daily summary data : #{daily_summary_report.inspect}")



  # delete local file
  File.delete(lifetime_upload_reposnse.data[:file_name]) if File.exist?(lifetime_upload_reposnse.data[:file_name])
  File.delete(daily_upload_reposnse.data[:file_name]) if File.exist?(daily_upload_reposnse.data[:file_name])

  template_name = GlobalConstant::PepoCampaigns.platform_usage_report_template
  template_vars = {
    daily_whitelisted_emails: daily_summary_report[:whitelisted_emails],
    daily_registrations: daily_summary_report[:registrations],
    daily_email_verifications: daily_summary_report[:double_opt_in],
    daily_mfa_setup: daily_summary_report[:is_mfa_setup],
    daily_token_setup: daily_summary_report[:token_setup],
    daily_client_stake_mint: daily_summary_report[:stake_and_mint],
    daily_client_atleast_one_transaction: daily_summary_report[:transactions],

    lifetime_whitelisted_emails: lifetime_summary_report[:whitelisted_emails],
    lifetime_registrations: lifetime_summary_report[:registrations],
    lifetime_email_verifications: lifetime_summary_report[:double_opt_in],
    lifetime_mfa_setup: lifetime_summary_report[:is_mfa_setup],
    lifetime_token_setup: lifetime_summary_report[:token_setup],
    lifetime_client_stake_mint: lifetime_summary_report[:stake_and_mint],
    lifetime_client_atleast_one_transaction: lifetime_summary_report[:transactions],

    unresolved_token_setup_errors: lifetime_summary_report[:ts_errors],
    unresolved_stake_mint_errors: lifetime_summary_report[:snm_errors],
    resolved_token_setup_errors: lifetime_summary_report[:resolved_ts_errors],
    resolved_stake_mint_errors: lifetime_summary_report[:resolved_snm_errors],
    date: Time.now.strftime("%Y-%m-%d"),

    daily_report_link: CGI.escape(daily_upload_reposnse.data[:presigned_url]),
    lifetime_report_link: CGI.escape(lifetime_upload_reposnse.data[:presigned_url])
  }

  recipient_emails = [
    'jason@ost.com',
    'ignas@ost.com',
    'chris@ost.com',
    'renee@ost.com',
    'jordan@ost.com',
    'marina@ost.com',
    'paul@ost.com',
    'paul.kuveke@ost.com',
    'mohit@ost.com',
    'kevin@ost.com',
    'jean@ost.com',
    'px@ost.com',
    'sunil@ost.com',
    'aman@ost.com',
    'akshay@ost.com',
    'bala@ost.com',
    'rachin@ost.com',
    'somashekhar@ost.com',
    'ben@ost.com',
    'kedar@ost.com'
  ]

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
