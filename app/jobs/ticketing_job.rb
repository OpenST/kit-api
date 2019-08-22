class TicketingJob < ApplicationJob

  queue_as GlobalConstant::Sidekiq.queue_name :default_medium_priority_queue

  # Perform
  #
  # * Author: Anagha
  # * Date: 16/04/2019
  # * Reviewed By:
  #
  def perform(params)

    init_params(params)

    r = create_issue_in_jira
    return r unless r.success?

    r = create_deal_in_pipedrive
    return r unless r.success?

    notify_devs

    success
  end

  # Init params
  #
  # * Author: Anagha
  # * Date: 16/04/2019
  # * Reviewed By:
  #
  # Sets @company_name, @first_name, @last_name, @email_address, @mobile_app_flag, @one_m_users_flag
  #
  def init_params(params)

    @company_name = params[:company_name]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @email_address = params[:email_address]
    @mobile_app_flag = params[:mobile_app_flag]
    @one_m_users_flag = params[:one_m_users_flag]

    @failed_logs = {}
  end

  # Create ticket in jira for enterprise company/organization
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  def create_issue_in_jira

    format_company_info_fields

    issue_params = {
      project_name:GlobalConstant::Jira.project_name,
      issue_type: GlobalConstant::Jira.task_issue_type,
      priority:GlobalConstant::Jira.medium_priority_issue,
      assignee: GlobalConstant::Jira.assignee_name,
      summary: get_issue_summary,
      description: get_issue_description
    }

    r = Ticketing::Jira::Issue.new(issue_params).perform

    @failed_logs = {
      debug_params: issue_params.to_hash
    }  unless r.success?

    success

  end

  # Create deal in pipedrive
  #
  # * Author: Dhananjay
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  def create_deal_in_pipedrive
    return success if @email_address.to_s.downcase.include?("ost.com")

    create_organization_resp = Ticketing::PipeDrive::Organization.new.create(@company_name)

    @failed_logs = {
      error_msg:create_organization_resp.to_hash,
      debug_params: @company_name
    } unless create_organization_resp.success?

    org_id = create_organization_resp[:data][:org_id]

    create_person_resp = Ticketing::PipeDrive::Person.new.create(@first_name, @last_name, @email_address, org_id)

    @failed_logs = {
      error_msg:create_organization_resp.to_hash,
      debug_params: {
        'first_name' => @first_name,
        'last_name' => @last_name,
        'email_address' => @email_address,
        'org_id' => org_id
      }
    } unless create_person_resp.success?

    person_id = create_person_resp[:data][:person_id]

    format_company_info_fields

    create_deal_resp = Ticketing::PipeDrive::Deal.new.create(@company_name, person_id, org_id, @one_m_users_flag_str, @mobile_app_flag_str)

    @failed_logs = {
      error_msg:create_deal_resp.to_hash,
      debug_params: {
        'company_name' => @company_name,
        'first_name' => @first_name,
        'last_name' => @last_name,
        'email_address' => @email_address,
        'person_id' => person_id,
        'org_id' => org_id,
        'one_m_users_flag_str' => @one_m_users_flag_str,
        'mobile_app_flag_str' => @mobile_app_flag_str
      }
    } unless create_deal_resp.success?

    deal_id = create_deal_resp[:data][:deal_id]

    success
  end

  # Send notification mail
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  def notify_devs
    ApplicationMailer.notify(
      data: @failed_logs,
      body: {email_address: @email_address,
             company_name: @company_name},
      subject: 'Exception in FormIntegrationJob'
    ).deliver if @failed_logs.present?
  end

  private

  # Get summary for jira ticket
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  # @returns [String]
  #
  def get_issue_summary
    get_summary_template % get_platform_registration
  end

  # Get summary template for jira ticket
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  # @returns [String]
  #
  def get_summary_template
    "Enterprise: %{company_name}"
  end

  # Get platform registration fields
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  # @returns [Hash]
  #
  def get_platform_registration
    {
      company_name: @company_name,
      first_name: @first_name,
      last_name: @last_name,
      email_address: @email_address,
      mobile_app_flag_str: @mobile_app_flag_str,
      one_m_users_flag_str: @one_m_users_flag_str
    }
  end

  # Get description for jira ticket
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  # @returns [String]
  #
  def get_issue_description
    get_description_template % get_platform_registration
  end

  # Get description template for jira ticket
  #
  # * Author: Anagha
  # * Date: 17/04/2019
  # * Reviewed By:
  #
  # @returns [String]
  #
  def get_description_template
    "Enterprise or Business? : %{one_m_users_flag_str}
     Company name: %{company_name}
     Does the client have an iOS or Android app? : %{mobile_app_flag_str}
     Super admin first name: %{first_name}
     Super admin last name: %{last_name}
     Email Address: [%{email_address}|mailto:%{email_address}]"
  end

  # format company info fields
  #
  # * Author: Dhananjay
  # * Date: 17/04/2019
  # * Reviewed By: Anagha
  #
  # @Sets @one_m_users_flag_str, @mobile_app_flag_str
  #
  def format_company_info_fields
    @one_m_users_flag_str = @one_m_users_flag.to_i == 1 ? 'Enterprise' : 'Business'
    @mobile_app_flag_str = @mobile_app_flag.to_i == 1 ? 'YES' : 'NO'
  end

end
