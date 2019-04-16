module Jira

  class CreateIssue

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By: Kedar
    #
    # @params [String] project_name (mandatory) - Project name
    # @params [String] issue_type (mandatory) - Issue type
    # @params [String] priority (optional) - Priority
    # @params [String] summary (mandatory) - Summary
    # @params [String] description (optional) - Description
    # @params [Array] labels (optional) - Labels
    # @params [String] assignee (optional) - Assignee
    # @return [Jira::CreateIssue]
    #
    def initialize(params)

      @project_name = params[:project_name]
      @issue_type = params[:issue_type]
      @priority = params[:priority]
      @summary = params[:summary]
      @description = params[:description] || ''
      @labels = params[:labels] || []
      @assignee = params[:assignee]

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
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      validation_errors = []

      validation_errors.push('invalid_labels') unless Util::CommonValidator.is_array?(@labels)
      validation_errors.push('invalid_summary') unless Util::CommonValidator.is_string?(@summary)
      validation_errors.push('invalid_project_name') unless Util::CommonValidator.is_string?(@project_name)
      validation_errors.push('invalid_description') unless Util::CommonValidator.is_string?(@description)
      validation_errors.push('invalid_issue_type') unless is_valid_issue_type?(@issue_type)
      validation_errors.push('invalid_priority') unless is_valid_priority?(@priority)


      return validation_error(
        'l_j_ci_1',
        'something_went_wrong',
        validation_errors,
        GlobalConstant::ErrorAction.default
      ) if validation_errors.present?

      success
    end

    # Is issue type valid
    #
    # * Author: Anagha
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def is_valid_issue_type?(issue_type)
      issues=[]
      issues.push(GlobalConstant::Jira.task_issue_type)
      issues.push(GlobalConstant::Jira.bug_issue_type)
      issues.push(GlobalConstant::Jira.story_issue_type)

      issues.include?(issue_type)
    end

    # Is priority valid
    #
    # * Author: Anagha
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def is_valid_priority?(priority)
      priorities=[]
      priorities.push(GlobalConstant::Jira.highest_priority_issue)
      priorities.push(GlobalConstant::Jira.high_priority_issue)
      priorities.push(GlobalConstant::Jira.medium_priority_issue)
      priorities.push(GlobalConstant::Jira.low_priority_issue)
      priorities.push(GlobalConstant::Jira.lowest_priority_issue)

      priorities.include?(priority)
    end

    # Create task in jira
    #
    # * Author: Anagha
    # * Date: 15/04/2018
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def create_task

      jira_config = GlobalConstant::Jira.jira_config

      client = JIRA::Client.new(jira_config)

      issue = client.Issue.build

      custom_params = {
        "fields" => {
          "assignee" => {"name" => @assignee},
          "description" => @description,
          "summary"   => @summary,
          "labels" => @labels,
          "project"   => {"key" => @project_name},
          "issuetype" => {"name" => @issue_type},
          "priority"  => {"name" => @priority}
        }
      }

      issue_response = issue.save(custom_params)

      return error_with_data(
        'l_j_ci_2',
        'error_in_issue_creation',
        GlobalConstant::ErrorAction.default
      ) unless issue_response

      success
    end

  end

end