module Util

  class CommonValidator

    REGEX_EMAIL = /\A[A-Z0-9]+[A-Z0-9_%+-]*(\.[A-Z0-9_%+-]{1,})*@(?:[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?\.)+[A-Z]{2,24}\z/i
    REGEX_TOKEN = /\A([a-z0-9=\-]*)\z/i
    REGEX_DOMAIN = /\A([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,4}\z/i

    # Check for integer-ness of an input
    #
    # * Author: Ankit
    # * Date: 15/01/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_integer?(object)
      return is_numeric?(object) && Float(object) == Integer(object) rescue false
    end

    # Check if input is an array
    #
    # * Author: Anagha
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_array?(object)
      return object.is_a?(Array)
    end

    # Check if input is string
    #
    # * Author: Anagha
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_string?(object)
      return object.is_a?(String)
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

    # Does password contains allowed characters and minimum size
    #
    # * Author: Puneet
    # * Date: 14/02/2018
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_min_length_of_password?(password)
      # Password should be 8 characters
      password.to_s.length >= 8
    end

    # Does password contains allowed characters and maximum size
    #
    # * Author: Dhananjay
    # * Date: 28/01/2020
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_max_length_of_password?(password)
      # Password should be less than 50 characters
      password.to_s.length <= 50
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
      name =~ /\A[A-Z0-9]+\z/i
    end

    # Is alphabetical string
    #
    # * Author: Ankit
    # * Date: 05/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_name?(name)
      name =~ /\A[A-Z]{1,30}\z/i
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
        stop_words = ["anal", "anus", "arse", "ballsack", "bitch", "biatch", "blowjob", "blow job", "bollock", "bollok", "boner", "boob", "bugger", "bum", "butt", "buttplug", "clitoris", "cock", "coon", "crap", "cunt", "dick", "dildo", "dyke", "fag", "feck", "fellate", "fellatio", "felching", "fuck", "f u c k", "fudgepacker", "fudge packer", "flange", "Goddamn", "God damn", "homo", "jerk", "Jew", "jizz", "Kike", "knobend", "knob end", "labia", "muff", "nigger", "nigga", "penis", "piss", "poop", "prick", "pube", "pussy", "scrotum", "sex", "shit", "s hit", "sh1t", "slut", "smegma", "spunk", "tit", "tosser", "turd", "twat", "vagina", "wank", "whore", "porn", "about", "stats", "search", "block", "transaction", "token", "address", "mainnet", "testnet"]
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

    # check if the transaction hash is a valid transaction hash
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_transaction_hash?(tx_hash)
      !(/\A(0x|0X)?[a-fA-F0-9]{64}\z/.match(tx_hash.to_s)).nil?
    end

    # Sanitize transaction hash
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @return [String] returns sanitized transaction hash
    #
    def self.sanitize_transaction_hash(tx_hash)
      transaction_hash = tx_hash.to_s.strip
      if (!transaction_hash.start_with?('0x') && !transaction_hash.start_with?('0X'))
        transaction_hash = '0x' + transaction_hash
      end
      transaction_hash
    end

    # Is the Email Domain valid
    #
    # * Author: Puneet
    # * Date: 18/03/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_domain?(domain)
      domain =~ REGEX_DOMAIN
    end

    # Is the Client Manager active/valid?
    #
    # * Author: Shlok
    # * Date: 25/03/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_active_admin?(privileges)
      privileges.exclude?(GlobalConstant::ClientManager.has_been_deleted_privilege) &&
        (
        privileges.include?(GlobalConstant::ClientManager.is_super_admin_privilege) ||
          privileges.include?(GlobalConstant::ClientManager.is_admin_privilege)
        )
    end

    # Is the Client Manager active/valid super admin?
    #
    # * Author: Shlok
    # * Date: 25/03/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_active_super_admin?(privileges)
      privileges.exclude?(GlobalConstant::ClientManager.has_been_deleted_privilege) &&
        (
        privileges.include?(GlobalConstant::ClientManager.is_super_admin_privilege)
        )
    end

    # Is the company name valid?
    #
    # * Author: Anagha
    # * Date: 08/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_company_name_valid?(company_name)

      # NOTE: Don't put length checks here as some chars like &,<,> reaching here become &lt; which would make our length checks void
      # Length check has been done for safety purposes.
      match_status = !(/\A[a-zA-Z0-9&£@$€¥\/.,:;«»\-\'\(\)\[\]\{\}\!\?\"\s]{3,100}\z/i.match(company_name)).nil?

      match_status && is_valid_guillemet?(company_name)

    end

    # if present, count of '«' and '»' should be same.
    #
    # * Author: Anagha
    # * Date: 08/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_guillemet?(company_name)
      return true unless (company_name.include?('«') || company_name.include?('»'))
      return company_name.count('«') == company_name.count('»')
    end

    # check if email is an OST email
    #
    # * Author: Puneet
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @return [Boolean] returns a boolean
    #
    def self.is_valid_ost_email?(email)
      return false unless is_valid_email?(email)
      buffer = email.split('@')
      buffer[1].downcase == 'ost.com'
    end

  end

end
