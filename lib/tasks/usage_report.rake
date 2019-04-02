desc "Usage: rake RAILS_ENV=staging usage_report"

task :usage_report => :environment do

  require('csv')

  whitelisted_email_rows = ManagerWhitelisting.select('identifier', 'created_at').where(
    kind: GlobalConstant::ManagerWhitelisting.email_kind).all

  whitelisted_emails = []

  lifetime_data_by_email = {}
  emails_registerred_today = []

  current_ts = Time.now.to_i
  day_start_ts = current_ts - 24.hours.to_i

  lifetime_summary_report = {
    whitelisted_emails: 0,
    registrations: 0,
    double_opt_in: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0
  }

  daily_summary_report = {
    whitelisted_emails: 0,
    registrations: 0,
    double_opt_in: 0,
    token_setup: 0,
    stake_and_mint: 0,
    transactions: 0
  }

  whitelisted_email_rows.each do |row|
    ## identifier is email in case of kind is email
    email = row.identifier
    whitelisted_emails << email
    lifetime_data_by_email[email] = {
      whitelisted_at: row.created_at,
      client_id: 0,
      is_verified_email: 0,
      registered_at: nil,
      stake_and_mint_done: 0,
      made_transactions: 0,
      token_deployment_status: GlobalConstant::ClientToken.not_deployed,
      token_symbol: ''
    }

    lifetime_summary_report[:whitelisted_emails] += 1

    if row.created_at.to_i > day_start_ts
      daily_summary_report[:whitelisted_emails] += 1
    end
  end

  manager_rows = Manager.where(
    status: GlobalConstant::Manager.active_status,
    email: whitelisted_emails).all

  client_ids = []

  manager_rows.each do |row|
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

  def generate_and_upload_csv(data_by_email, report_type)
    csv_data = []

    # prepare CSV Data

    # append headers
    csv_data.push([
                             'email',
                             'whitelisted_at',
                             'registered_at',
                             'double opt in done',
                             'token deploy status',
                             'token symbol',
                             'stake and mint done',
                             'performed transactions'
                           ])

    data_by_email.each do |email, data|
      buffer = []
      buffer.push(email)
      buffer.push(data[:whitelisted_at])
      buffer.push(data[:registered_at])
      buffer.push(data[:is_verified_email] == 1 ? 'YES' : 'NO')
      buffer.push(data[:token_deployment_status])
      buffer.push(data[:token_symbol])
      buffer.push(data[:stake_and_mint_done] == 1 ? 'YES' : 'NO')
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

  lifetime_upload_reposnse = generate_and_upload_csv(lifetime_data_by_email, 'lifetime')
  return lifetime_upload_reposnse unless lifetime_upload_reposnse.success?

  daily_data_by_email = {}
  emails_registerred_today.each do |email|
    daily_data_by_email[email] = lifetime_data_by_email[email]
  end

  daily_upload_reposnse = generate_and_upload_csv(daily_data_by_email, 'daily')
  return daily_upload_reposnse unless daily_upload_reposnse.success?

  puts("Lifetime secured URL : #{lifetime_upload_reposnse.data[:presigned_url]}")
  puts("Lifetime summary data : #{lifetime_summary_report.inspect}")

  puts("Daily secured URL : #{daily_upload_reposnse.data[:presigned_url]}")
  puts("Daily summary data : #{daily_summary_report.inspect}")



  # delete local file
  File.delete(lifetime_upload_reposnse.data[:file_name]) if File.exist?(lifetime_upload_reposnse.data[:file_name])
  File.delete(daily_upload_reposnse.data[:file_name]) if File.exist?(daily_upload_reposnse.data[:file_name])

end
