module Formatter

  class DoNothing

    def initialize(entity_data)
      @entity_data = entity_data
    end

    def perform
      @entity_data
    end

  end

end
