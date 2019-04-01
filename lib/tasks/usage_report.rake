desc "Usage: rake RAILS_ENV=staging usage_report"
task :usage_report => :environment do

  whitelisted_email_rows = ManagerWhitelisting.select('identifier', 'created_at').where(
    kind: GlobalConstant::ManagerWhitelisting.email_kind).all

  whitelisted_emails = []

  data_by_email = {}

  summary_report = {
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
    data_by_email[email] = {
      whitelisted_at: row.created_at,
      client_id: 0,
      is_verified_email: 0,
      registered_at: nil,
      stake_and_mint_done: 0,
      made_transactions: 0,
      token_deployment_status: GlobalConstant::ClientToken.not_deployed,
      token_symbol: ''
    }

    summary_report[:whitelisted_emails] += 1
  end

  manager_rows = Manager.where(
    status: GlobalConstant::Manager.active_status,
    email: whitelisted_emails).all

  client_ids = []

  manager_rows.each do |row|
    client_id = row.current_client_id

    client_ids << client_id
    summary_report[:registrations] += 1

    data_by_email[row.email][:client_id] = client_id
    data_by_email[row.email][:registered_at] = row.created_at

    if row.send("#{GlobalConstant::Manager.has_verified_email_property}?")
      data_by_email[row.email][:is_verified_email] = 1
      summary_report[:double_opt_in] += 1
    else
      data_by_email[row.email][:is_verified_email] = 0
    end

    dashboard_service_response = DashboardManagement::Get.new({client_id: client_id}).perform

    p("---------dashboard_service_response------#{dashboard_service_response.inspect}")
    if dashboard_service_response.success?
      if dashboard_service_response.data[:token]
        data_by_email[row.email][:token_deployment_status] = dashboard_service_response.data[:token][:status]
        data_by_email[row.email][:token_symbol] = dashboard_service_response.data[:token][:symbol]
        summary_report[:token_setup] += 1
      end

      if dashboard_service_response.data[:dashboard_details][:total_supply].to_f > 0
        data_by_email[row.email][:stake_and_mint_done] = 1
        summary_report[:stake_and_mint] += 1
      end

      if dashboard_service_response.data[:dashboard_details][:circulating_supply].to_f > 0
        data_by_email[row.email][:made_transactions] = 1
        summary_report[:transactions] += 1
      end
    end

  end

  p("---1------data_by_email------")
  p(data_by_email)
  p("---1------data_by_email------")

  p(summary_report)

end
