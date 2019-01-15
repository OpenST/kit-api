module Util

  class CommonValidator
    
    REGEX_EMAIL = /\A[A-Z0-9]+[A-Z0-9_%+-]*(\.[A-Z0-9_%+-]{1,})*@(?:[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?\.)+[A-Z]{2,24}\Z/mi
    REGEX_EMAIL_DOMAIN = /\A@(?:[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?\.)+[A-Z]{2,24}\Z/mi
    REGEX_TOKEN = /^[ \w\/=+%-].*$/mi

    # Check for integer-ness of an input
    #
    # * Author: Ankit
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_integer?(object)
      true if Integer(object) rescue false
    end

    # Check for numeric-ness of an input
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_numeric?(object)
      true if Float(object) rescue false
    end

    # front end sends 0 / 1 instead of boolean true / false
    # Check for boolean-ness of an input
    # check if '0' or '1' was passed
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_boolean_string?(object)
      %w(0 1).include?(object.to_s)
    end

    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_true_boolean_string?(object)
      object.to_s == '1'
    end

    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_false_boolean_string?(object)
      object.to_s == '0'
    end

    # Is boolean
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_boolean?(object)
      [
          true,
          false
      ].include?(object)
    end

    # Check for numeric-ness of multiple inputs
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.are_numeric?(objects)
      return false unless objects.is_a?(Array)
      are_numeric = true
      objects.each do |object|
        unless self.is_numeric?(object)
          are_numeric = false
          break
        end
      end
      return are_numeric
    end

    # Is the given object Hash
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_a_hash?(obj)
      obj.is_a?(Hash) || obj.is_a?(ActionController::Parameters)
    end

    # Is the Email a Valid Email
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_email?(email)
      email =~ REGEX_EMAIL
    end

    # Is the Email Domain valid
    #
    # * Author: Shlok
    # * Date: 14/09/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_email_domain?(domain)
      domain =~ REGEX_EMAIL_DOMAIN
    end

    # Is the Invite token valid
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_token?(token)
      token =~ REGEX_TOKEN
    end

    # Is the Email a Valid Email
    #
    # * Author: Puneet
    # * Date: 06/04/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_whitelisted_email?(email)
      downcased_email = email.strip.downcase
      is_valid_email?(email) &&
          (is_email_from_allowed_domains?(downcased_email) || whitelisted_emails.include?(downcased_email))
    end

    # list of whitelisted emails
    #
    # * Author: Puneet
    # * Date: 06/04/2017
    # * Reviewed By:
    #
    # @return [Arrray]
    #
    def self.whitelisted_emails
      r = CacheManagement::ClientWhitelistedEmails.new().fetch
      r[:emails] || []
    end

    # Is the Email a OST Email
    #
    # * Author: Puneet
    # * Date: 06/04/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_email_from_allowed_domains?(email)
      /w*@(#{allowed_domains.join('|')})$/.match(email).present?
    end

    # List of Domains which we need to support
    #
    # * Author: Puneet
    # * Date: 06/04/2017
    # * Reviewed By:
    #
    # @return [Array] returns a boolean
    #
    def self.allowed_domains
      r = CacheManagement::ClientWhitelistedDomains.new().fetch
      r[:domains] || []
    end

    # Does password contains allowed characters and size
    #
    # * Author: Puneet
    # * Date: 14/02/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_password?(password)
      # Password should be 8 characters
      password.to_s.length >= 8
    end

    # Is alpha numeric string
    #
    # * Author: Puneet
    # * Date: 20/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_alphanumeric?(name)
      name =~ /\A[A-Z0-9]+\Z/i
    end

    # Should Email be send to this email & this env
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_email_send_allowed?(email)
      return false unless is_valid_email?(email)
      Rails.env.production? || [
          ''
      ].include?(email)
    end

    # check if the addr is a valid address
    #
    # * Author: Puneet
    # * Date: 12/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_ethereum_address?(addr)
      !(/\A(0x|0X)?[a-fA-F0-9]{40}\z/.match(addr.to_s)).nil?
    end

    # Sanitize Ethereum Address
    #
    # * Author: Abhay
    # * Date: 31/10/2017
    # * Reviewed By: Puneet
    #
    # @return [String] returns sanitized ethereum address
    #
    def self.sanitize_ethereum_address(address)
      ethereum_address = address.to_s.strip
      if (!ethereum_address.start_with?('0x') && !ethereum_address.start_with?('0X'))
        ethereum_address = '0x' + ethereum_address
      end
      ethereum_address
    end

    # check if string has stop words or not
    #
    #
    # * Author: Puneet
    # * Date: 22/02/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.has_stop_words?(str)
      if str.blank?
        return false
      else
        stop_words = ["anal", "anus", "arse", "ballsack", "bitch", "biatch", "blowjob", "blow job", "bollock", "bollok", "boner", "boob", "bugger", "bum", "butt", "buttplug", "clitoris", "cock", "coon", "crap", "cunt", "dick", "dildo", "dyke", "fag", "feck", "fellate", "fellatio", "felching", "fuck", "f u c k", "fudgepacker", "fudge packer", "flange", "Goddamn", "God damn", "homo", "jerk", "Jew", "jizz", "Kike", "knobend", "knob end", "labia", "muff", "nigger", "nigga", "penis", "piss", "poop", "prick", "pube", "pussy", "scrotum", "sex", "shit", "s hit", "sh1t", "slut", "smegma", "spunk", "tit", "tosser", "turd", "twat", "vagina", "wank", "whore", "porn"]
        reg_ex = /\b(?:#{ stop_words.join('|') })\b/i
        return (str.gsub(reg_ex, '') != str) ? true : false
      end
    end

    # check if it is main env
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_mainnet_env?
      @i_mn_env ||= GlobalConstant::Base.sub_environment_name == GlobalConstant::Environment.main_sub_environment
    end

    # check if it is sandbox env
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_sandbox_env?
      @i_mn_env ||= GlobalConstant::Base.sub_environment_name == GlobalConstant::Environment.sandbox_sub_environment
    end

    # check if string is a valid Token Symbol
    #
    # * Author: Puneet
    # * Date: 22/02/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_token_symbol?(str)
      length = str.length
      return false if length > 4 || length < 3
      (str =~ /\A[a-z][0-9a-z]*\z/i).present?
    end

    # check if string is a valid Token name
    #
    # * Author: Puneet
    # * Date: 22/02/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_token_name?(str)
      length = str.length
      return false if length > 20 || length < 3
      (str =~ /\A[a-z][a-z0-9]*[\s]*[0-9a-z]*[\s]*[0-9a-z]*\z/i).present?
    end

  end

end
