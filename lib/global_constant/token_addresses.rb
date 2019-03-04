# frozen_string_literal: true
module GlobalConstant

  class TokenAddresses

    class << self

      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end

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

      def origin_admin_address_kind
        'origin_admin_address_kind'
      end

      def aux_admin_address_kind
        'aux_admin_address_kind'
      end

      def origin_worker_address_kind
        'origin_worker_address_kind'
      end

      def aux_worker_address_kind
        'aux_worker_address_kind'
      end

      def aux_funder_address_kind
        'aux_funder_address_kind'
      end

      def white_listed_address_kind
        'white_listed_address_kind'
      end

      def tx_worker_address_kind
        'tx_worker_address_kind'
      end

      def token_user_ops_worker_address_kind
        'token_user_ops_worker_address_kind'
      end

      def recovery_controller_address_kind
        'recovery_controller_address_kind'
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

      def token_rules_contract
        'token_rules_contract'
      end

      def token_holder_master_copy_contract
        'token_holder_master_copy_contract'
      end

      def user_wallet_factory_contract
        'user_wallet_factory_contract'
      end

      def gnosis_safe_multisig_master_copy_contract
        'gnosis_safe_multisig_master_copy_contract'
      end

      def proxy_factory_contract
        'proxy_factory_contract'
      end

      def delayed_recovery_module_master_copy_contract
        'delayed_recovery_module_master_copy_contract'
      end

      def create_add_modules_contract
        'create_add_modules_contract'
      end

      def unique_kinds
        [
          self.owner_address_kind,
          self.origin_admin_address_kind,
          self.aux_admin_address_kind,
          self.origin_organization_contract,
          self.aux_organization_contract,
          self.branded_token_contract,
          self.utility_branded_token_contract,
          self.token_gateway_contract,
          self.token_co_gateway_contract,
          self.simple_stake_contract,
          self.aux_funder_address_kind,
          self.token_user_ops_worker_address_kind,
          self.recovery_controller_address_kind,
          self.token_rules_contract,
          self.token_holder_master_copy_contract,
          self.user_wallet_factory_contract,
          self.gnosis_safe_multisig_master_copy_contract,
          self.proxy_factory_contract,
          self.delayed_recovery_module_master_copy_contract,
          self.create_add_modules_contract
           ]

      end

    end

  end

end