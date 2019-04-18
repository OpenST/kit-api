module GlobalConstant

  class Jira

    ### Issue types start ###
    def self.task_issue_type
      return 'Task'
    end

    def self.bug_issue_type
      return 'Bug'
    end

    def self.story_issue_type
      return 'Story'
    end

    ### Issue types end ###

    ### Issue priorities start ###
    def self.highest_priority_issue
      return "Highest"
    end

    def self.high_priority_issue
      return "High"
    end

    def self.medium_priority_issue
      return "Medium"
    end

    def self.low_priority_issue
      return "Low"
    end

    def self.lowest_priority_issue
      return "Lowest"
    end

    ### Issue priorities end ###

    def self.username
      config[:username]
    end

    def self.site
      'https://ostdotcom.atlassian.net:443/'
    end

    def self.password
      config[:password]
    end

    def self.context_path
      ''
    end

    def self.auth_type
      config[:auth_type]
    end

    def self.project_name
      config[:project_name]
    end

    # Returns jira config
    #
    # * Author: Anagha
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    #
    def self.jira_config
      {
        :username => username,
        :password => password,
        :site => site,
        :context_path => context_path,
        :auth_type => auth_type
      }
    end

    private

    def self.config
      GlobalConstant::Base.jira_config
    end

  end

end