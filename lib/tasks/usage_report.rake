desc "Usage: rake RAILS_ENV=staging usage_report"
task :usage_report => :environment do

  whitelisted_email_rows = ManagerWhitelisting.select('identifier', 'created_at').where(
    kind: GlobalConstant::ManagerWhitelisting.email_kind).all

  whitelisted_emails = []

  data_by_email = {}
  data_by_client_id = {}

  whitelisted_email_rows.each do |row|
    ## identifier is email in case of kind is email
    email = row.identifier
    whitelisted_emails << email
    data_by_email[email] = {whitelisted_at: row.created_at}
  end

  manager_rows = Manager.where(
    status: GlobalConstant::Manager.active_status,
    email: whitelisted_emails).all

  client_ids = []

  manager_rows.each do |row|
    client_id = row.current_client_id

    client_ids << client_id
    data_by_client_id[client_id] = {email: row.email}

    data_by_email[row.email][:client_id] = client_id
    data_by_email[row.email][:is_verified_email] = (row.send("#{GlobalConstant::Manager.has_verified_email_property}?") ? 1 : 0)
    data_by_email[row.email][:registered_at] = row.created_at


  end

  p("---1------data_by_email------#{data_by_email.inspect}")

  Token.where(client_id: client_ids).all.each do |token|
    email = data_by_client_id[token.client_id][:email]
    data_by_email[email][:token_deployment_status] = token.status
  end

  dashboard_service_response = DashboardManagement::Get.new({client_id: 10098}).perform
  p("dashboard_service_response----------------")
  p(dashboard_service_response.data)

  ## p(data_by_email)
end
