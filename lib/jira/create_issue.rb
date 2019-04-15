module Jira

  class CreateIssue

    # Initialize
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By:
    #
    # @params [String] project_name (mandatory) - Project name
    # @params [Integer] issue_type (String) - issue_type
    # @params [Integer] priority (String) - priority
    # @params [Integer] summary (String) - summary
    # @params [Integer] description (mandatory) - description
    # @params [Integer] labels (optional) - labels
    #
    # @return [ManagerManagement::Team::Get]
    #
    def initialize(params)

      @project_name = params[:project_name]
      @issue_type = params[:issue_type]
      @priority = params[:priority]
      @summary = params[:summary]
      @description = params[:description]
      @labels = params[:labels]

    end


    def perform

      jira_config = GlobalConstant::Jira.jira_config

      client = JIRA::Client.new(jira_config)

      issue = client.Issue.build
      Rails.logger.info("======== Jira_config ======== #{jira_config}")

      custom_params = {
        "fields" => {
          "assignee" => {"name" => "anagha"}, # From environment
          "description" => @description,
          "summary"   => @summary,
          "labels" => @labels,
          "project"   => {"key" => @project_name},
          "issuetype" => {"name" => @issue_type},
          "priority"  => {"id" => @priority}
        }
      }

      Rails.logger.info("======== Custom params ======== #{custom_params}")
      issue.save(custom_params)

    end

  end

end