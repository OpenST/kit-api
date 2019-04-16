module Jira

  class CreateIssue

    include Util::ResultHelper

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
    # @return [Jira::CreateIssue]
    #
    def initialize(params)

      @project_name = params[:project_name]
      @issue_type = params[:issue_type]
      @priority = params[:priority]
      @summary = params[:summary]
      @description = params[:description]
      @labels = params[:labels] || []

    end


    # Perform
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      r = validate_and_sanitize
      return r unless r.success?

      r = create_task
      return r unless r.success?

      success_with_data({})

    end

    # Validate
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      validation_errors = []

      validation_errors.push('invalid_labels') unless Util::CommonValidator.is_array?(@labels)

      return validation_error(
        'l_j_ci_1',
        'something_went_wrong',
        validation_errors,
        GlobalConstant::ErrorAction.default
      ) if validation_errors.present?

      success
    end

    # Create task in jira
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def create_task

      jira_config = GlobalConstant::Jira.jira_config

      client = JIRA::Client.new(jira_config)

      issue = client.Issue.build

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

      issue_response = issue.save(custom_params)

      return error_with_data(
        'l_j_ci_1',
        'error_in_issue_creation',
        GlobalConstant::ErrorAction.default
      ) unless issue_response

      success
    end

  end

end