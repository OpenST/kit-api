# frozen_string_literal: true
module GlobalConstant

  class TokenAddresses

    class << self

      def aux
        'aux'
      end

      def origin
        'origin'
      end

      def gateway
        'gateway'
      end

      def co_gateway
        'co_gateway'
      end

      def ubt
        'ubt'
      end

      def owner
        'owner'
      end

      def funder
        'funder'
      end

      def owner_address_kind
        'owner_address_kind'
      end

      def admin_address_kind
        'admin_address_kind'
      end

      def worker_address_kind
        'worker_address_kind'
      end

      def white_listed_address_kind
        'white_listed_address_kind'
      end

      def origin_organization_contract
        'origin_organization_contract'
      end

      def aux_organization_contract
        'aux_organization_contract'
      end

      def branded_token_contract
        'branded_token_contract'
      end

      def utility_branded_token_contract
        'utility_branded_token_contract'
      end

      def token_gateway_contract
        'token_gateway_contract'
      end

      def token_co_gateway_contract
        'token_co_gateway_contract'
      end

      def simple_stake_contract
        'simple_stake_contract'
      end

      def unique_kinds
        [
          self.owner_address_kind,
          self.admin_address_kind,
          self.origin_organization_contract,
          self.aux_organization_contract,
          self.branded_token_contract,
          self.utility_branded_token_contract,
          self.token_gateway_contract,
          self.token_co_gateway_contract,
          self.simple_stake_contract
           ]
      end

    end

  end

end