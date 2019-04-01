desc "Usage: rake RAILS_ENV=staging usage_report"
task :usage_report => :environment do

  whitelisted_email_rows = ManagerWhitelisting.select('identifier', 'created_at').where(
    kind: GlobalConstant::ManagerWhitelisting.email_kind).all

  whitelisted_emails = []

  data_by_email = {}

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
  end

  manager_rows = Manager.where(
    status: GlobalConstant::Manager.active_status,
    email: whitelisted_emails).all

  client_ids = []

  manager_rows.each do |row|
    client_id = row.current_client_id

    client_ids << client_id

    data_by_email[row.email][:client_id] = client_id
    data_by_email[row.email][:is_verified_email] = (row.send("#{GlobalConstant::Manager.has_verified_email_property}?") ? 1 : 0)
    data_by_email[row.email][:registered_at] = row.created_at

    dashboard_service_response = DashboardManagement::Get.new({client_id: client_id}).perform

    p("---------dashboard_service_response------#{dashboard_service_response.inspect}")
    if dashboard_service_response.success?
      if dashboard_service_response.data[:token]
        data_by_email[row.email][:token_deployment_status] = dashboard_service_response.data[:token][:status]
        data_by_email[row.email][:token_symbol] = dashboard_service_response.data[:token][:symbol]
      end

      if dashboard_service_response.data[:dashboard_details][:total_supply].to_f > 0
        data_by_email[row.email][:stake_and_mint_done] = 1
      end

      if dashboard_service_response.data[:dashboard_details][:circulating_supply].to_f > 0
        data_by_email[row.email][:made_transactions] = 1
      end
    end

  end

  p("---1------data_by_email------")
  p(data_by_email)

end
