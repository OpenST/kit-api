module Formatter

  class Factory

    def self.get_instance(entity_name, entity_data)

      case entity_name

      when :stake_currencies
        return Formatter::StakeCurrencies.new(entity_data)
      when :all_stake_currencies
        return Formatter::StakeCurrencies.new(entity_data)
      else
        return Formatter::DoNothing.new(entity_data)
      end

    end

  end


end