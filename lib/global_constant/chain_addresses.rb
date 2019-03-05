# frozen_string_literal: true
module GlobalConstant

  class ChainAddresses

    class << self

      # Statuses start here.
      def active_status
        'active'
      end

      def inactive_status
        'inactive'
      end
      # Statuses end here.

      # Deployed chain kinds start here.
      def aux
        'aux'
      end

      def origin
        'origin'
      end
      # Deployed chain kinds end here.

      def aux_deployer_kind
        'aux_deployer_kind'
      end

      def origin_deployer_kind
        'origin_deployer_kind'
      end

      def st_contract_owner_kind
        'st_contract_owner_kind'
      end

      def st_contract_admin_kind
        'st_contract_admin_kind'
      end

      def st_contract_kind
        'st_contract_kind'
      end

      def st_prime_contract_kind
        'st_prime_contract_kind'
      end

      def st_org_contract_kind
        'st_org_contract_kind'
      end

      def st_prime_org_contract_kind
        'st_prime_org_contract_kind'
      end

      def master_internal_funder_kind
        'master_internal_funder_kind'
      end

      def st_org_contract_owner_kind
        'st_org_contract_owner_kind'
      end

      def st_prime_org_contract_owner_kind
        'st_prime_org_contract_owner_kind'
      end

      def origin_anchor_org_contract_owner_kind
        'origin_anchor_org_contract_owner_kind'
      end

      def aux_anchor_org_contract_owner_kind
        'aux_anchor_org_contract_owner_kind'
      end

      def aux_price_oracle_contract_owner_kind
        'aux_price_oracle_contract_owner_kind'
      end

      def st_org_contract_admin_kind
        'st_org_contract_admin_kind'
      end

      def st_prime_org_contract_admin_kind
        'st_prime_org_contract_admin_kind'
      end

      def origin_anchor_org_contract_admin_kind
        'origin_anchor_org_contract_admin_kind'
      end

      def aux_anchor_org_contract_admin_kind
        'aux_anchor_org_contract_admin_kind'
      end

      def aux_price_oracle_contract_admin_kind
        'aux_price_oracle_contract_admin_kind'
      end

      def st_org_contract_worker_kind
        'st_org_contract_worker_kind'
      end

      def st_prime_org_contract_worker_kind
        'st_prime_org_contract_worker_kind'
      end

      def origin_anchor_org_contract_worker_kind
        'origin_anchor_org_contract_worker_kind'
      end

      def aux_anchor_org_contract_worker_kind
        'aux_anchor_org_contract_worker_kind'
      end

      def origin_anchor_org_contract_kind
        'origin_anchor_org_contract_kind'
      end

      def aux_anchor_org_contract_kind
        'aux_anchor_org_contract_kind'
      end

      def origin_anchor_contract_kind
        'origin_anchor_contract_kind'
      end

      def aux_anchor_contract_kind
        'aux_anchor_contract_kind'
      end

      def origin_mpp_lib_contract_kind
        'origin_mpp_lib_contract_kind'
      end

      def aux_mpp_lib_contract_kind
        'aux_mpp_lib_contract_kind'
      end

      def origin_mb_lib_contract_kind
        'origin_mb_lib_contract_kind'
      end

      def aux_mb_lib_contract_kind
        'aux_mb_lib_contract_kind'
      end

      def origin_gateway_lib_contract_kind
        'origin_gateway_lib_contract_kind'
      end

      def aux_gateway_lib_contract_kind
        'aux_gateway_lib_contract_kind'
      end

      def origin_gateway_contract_kind
        'origin_gateway_contract_kind'
      end

      def aux_co_gateway_contract_kind
        'aux_co_gateway_contract_kind'
      end

      def aux_sealer_kind
        'aux_sealer_kind'
      end

      def st_simple_stake_contract_kind
        'st_simple_stake_contract_kind'
      end

      def origin_granter_kind
        'origin_granter_kind'
      end

      def origin_default_bt_org_contract_admin_kind
        'origin_default_bt_org_contract_admin_kind'
      end

      def origin_default_bt_org_contract_worker_kind
        'origin_default_bt_org_contract_worker_kind'
      end

      def inter_chain_facilitator_kind
        'inter_chain_facilitator_kind'
      end

      def aux_price_oracle_contract_kind
        'aux_price_oracle_contract_kind'
      end

      def aux_price_oracle_contract_worker_kind
        'aux_price_oracle_contract_worker_kind'
      end

      def non_unique_kinds
        [
          self.st_org_contract_worker_kind,
          self.st_prime_org_contract_worker_kind,
          self.origin_anchor_org_contract_worker_kind,
          self.aux_anchor_org_contract_worker_kind,
          self.aux_sealer_kind,
          self.aux_price_oracle_contract_worker_kind
        ]

      end

    end

  end

end