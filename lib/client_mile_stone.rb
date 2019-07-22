class ClientMileStone

  include Util::ResultHelper

  # Initialize
  #
  # @params [Number] client_id (mandatory) - client id
  # @params [Number] manager_id (optional) - manager id
  #
  # @return [ClientMileStone]
  #
  def initialize(params)
    @client_id = params[:client_id]
    @manager_id = params[:manager_id]

    @attributes_hash = {}
  end

  # Update client mile stone attributes for all admins in pepo campaigns
  #
  # * Author: Santhosh
  # * Date: 16/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def update_mile_stone_attributes_for_admins

    r = fetch_client_mile_stones
    return r unless r.success?

    client_mile_stones = r.data[:set_mile_stones]

    return success if client_mile_stones.length == 0

    ClientManager.admins(@client_id).all.each do |client_manager|

      r = Email::HookCreator::UpdateContact.new(
          receiver_entity_id: client_manager[:manager_id],
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
          custom_attributes: @attributes_hash,
          user_settings: {}
      ).perform
    end

    success
  end

  # Update client mile stone attributes for current admin in pepo campaigns
  #
  # * Author: Santhosh
  # * Date: 16/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def update_mile_stones_for_current_admin

    r = fetch_client_mile_stones
    return r unless r.success?

    client_mile_stones = r.data[:set_mile_stones]

    return success if client_mile_stones.length == 0

    Email::HookCreator::UpdateContact.new(
        receiver_entity_id: @manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        custom_attributes: @attributes_hash,
        user_settings: {}
    ).perform

    success
  end

  private
  # Fetch client mile stones reached
  #
  # * Author: Santhosh
  # * Date: 16/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_client_mile_stones

    client_mile_stones = Client.sandbox_client_mile_stones

    client = Client.where(id: @client_id).first
    client = client.formatted_cache_data

    set_mile_stones = []

    # move this code to a lib
    client_mile_stones.each do |mile_stone, val|
      set_mile_stones << mile_stone if client[:sandbox_statuses].present? && client[:sandbox_statuses].include?(mile_stone)
    end

    set_mile_stones.each do |mile_stone|
      pc_attribute = mile_stone.split("#{GlobalConstant::Environment.sandbox_sub_environment}_")[1]  # Removing the env prefix

      # Since there are different attribute names compared to pepo campaign
      if mile_stone == GlobalConstant::Client.sandbox_registered_in_mappy_server_status
        pc_attribute = GlobalConstant::PepoCampaigns.ost_wallet_setup
      end

      @attributes_hash[pc_attribute] = GlobalConstant::PepoCampaigns.attribute_set
    end

    success_with_data({ set_mile_stones: set_mile_stones })
  end
end