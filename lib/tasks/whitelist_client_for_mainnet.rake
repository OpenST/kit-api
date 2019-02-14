# Whitelist client for mainnet
#
# * Author: Puneet
# * Date: 22/01/2018
# * Reviewed By:
#
desc "Usage: rake RAILS_ENV=development whitelist_client_for_mainnet EMAIL=a@ost.com CONFIG_GROUP_ID=1 TOKEN_USERS_SHARD_NUMBER=2 BALANCE_SHARD_NUMBER=2"
task :whitelist_client_for_mainnet => :environment do

  @email = ENV['EMAIL'].to_s.downcase
  @config_group_id = ENV['CONFIG_GROUP_ID'].to_i
  @token_users_shard_number = ENV['TOKEN_USERS_SHARD_NUMBER'].to_i
  @balance_shard_number = ENV['BALANCE_SHARD_NUMBER'].to_i

  STDOUT.puts "EMAIL to be activated for mainnet: #{@email}"
  STDOUT.puts "CONFIG_GROUP_ID: #{@config_group_id}"
  STDOUT.puts "TOKEN_USERS_SHARD_NUMBER: #{@token_users_shard_number}"
  STDOUT.puts "BALANCE_SHARD_NUMBER: #{@balance_shard_number}"

  if @config_group_id == 0
    STDOUT.puts "You are trying to assign an existing chain. Are you Sure ?"
    begin
      config_group_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(config_group_input)
  else
    STDOUT.puts "You are trying to preassign a chain with config_group_id: #{@config_group_id} . Are you Sure ?"
    begin
      config_group_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(config_group_input)
  end

  STDOUT.puts "config_group_input: #{config_group_input}"

  if @token_users_shard_number == 0
    STDOUT.puts "You are leaving shard allocation for users as ROUND ROBIN. Are you Sure ?"
    begin
      token_shard_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(token_shard_input)
  else
    STDOUT.puts "You are forcing shard allocation for users to shard number: #{@token_users_shard_number}. Are you Sure ?"
    begin
      token_shard_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(token_shard_input)
  end

  if @balance_shard_number == 0
    STDOUT.puts "You are leaving shard allocation for balances as ROUND ROBIN. Are you Sure ?"
    begin
      balance_shard_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(balance_shard_input)
  else
    STDOUT.puts "You are forcing shard allocation for balances to shard number: #{@balance_shard_number}. Are you Sure ?"
    begin
      balance_shard_input = STDIN.gets.strip.downcase
    end until %w(y n).include?(balance_shard_input)
  end

  if (@token_users_shard_number != 0 && @balance_shard_number == 0) || (@token_users_shard_number == 0 && @balance_shard_number != 0)
    STDOUT.puts "One of token/balance shard is missing. Please rerun with proper inputs. Exiting..."
    exit
  end

  if config_group_input == 'y' && (token_shard_input == 'y' && balance_shard_input == 'y')
    STDOUT.puts "Proceeding with whitelisting of #{@email} using config_group_id: #{@config_group_id} & #{@token_users_shard_number} & #{@balance_shard_number}"
    Rake::Task["perform_whitelist_client_for_mainnet"].reenable
    Rake::Task["perform_whitelist_client_for_mainnet"].invoke
  else
    # We know at this point that they've explicitly said no,
    STDOUT.puts "Aborting execution"
  end

end

task :perform_whitelist_client_for_mainnet => :environment do

  params = {
    email: @email,
    config_group_id: @config_group_id
  }

  if @token_users_shard_number > 0
    params[:token_users_shard_number] = @token_users_shard_number
  end

  if @balance_shard_number > 0
    params[:balance_shard_number] = @balance_shard_number
  end

  r = AdminManagement::Whitelist::Client.new(params).perform

  if r.success?
    STDOUT.puts "Successfully Whitelisted !!!!"
  else
    STDOUT.puts "Successfully Failed !!!!: #{r.to_json}"
  end

end