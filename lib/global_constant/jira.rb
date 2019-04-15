module GlobalConstant

  class Jira

    # Returns jira config
    #
    # * Author: Anagha
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    #

    def self.task_issue_type
      return 'Task'
    end

    def self.bug_issue_type
      return 'Bug'
    end



    def self.low_priority_issue
      return "1"
    end

    def self.medium_priority_issue
      return "3"
    end

    def self.high_priority_issue
      return "2"
    end


    def self.username
      config[:username]
    end

    def self.site
      config[:site]
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

    def self.jira_config
      {
        :username => username,
        :password => password,
        :site => site,
        :context_path => context_path,
        :auth_type => auth_type
      }
    end

    def self.config
      GlobalConstant::Base.jira_config
    end

  end

end