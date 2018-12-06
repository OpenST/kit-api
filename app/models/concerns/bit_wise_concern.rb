module BitWiseConcern

  extend ActiveSupport::Concern
  included do

    def fetch_value_from_ar_object(column_name)
      send(column_name) || 0
    end

    buffer = self.bit_wise_columns_config.inject([]) do |buffer, (_, values_hash)|
      buffer += values_hash.keys
    end
    fail "BIT_WISE_COLUMNS does not contain unique keys #{self.bit_wise_columns_config}" if buffer.uniq!.present?

    self.singleton_class.send(:define_method, 'get_set_bits') { |bit_value|
      (0...bit_value.bit_length).map { |n| bit_value[n] << n }.reject(&:zero?)
    }

    self.bit_wise_columns_config.each do |column_name, values_hash|

      self.singleton_class.send(:define_method, "inverted_values_for_#{column_name}") {
        value_from_cache = instance_variable_get("@i_values_for_#{column_name}")
        if value_from_cache.present?
          value_from_cache
        else
          value = send("values_for_#{column_name}").invert
          instance_variable_set("@i_values_for_#{column_name}", value)
        end
      }

      self.singleton_class.send(:define_method, "values_for_#{column_name}") {
        value_from_cache = instance_variable_get("@values_for_#{column_name}")
        if value_from_cache.present?
          value_from_cache
        else
          instance_variable_set("@values_for_#{column_name}", values_hash)
        end
      }

      self.singleton_class.send(:define_method, "get_bits_info_for_#{column_name}") { |bit_value|
        set_bits = get_set_bits(bit_value)
        values_map = send("inverted_values_for_#{column_name}")
        set_values = set_bits.map{|value| values_map[value]}
        unset_values = (values_map.keys - set_bits).map{|value| values_map[value]}
        {
            set: set_values,
            unset: unset_values
        }
      }

      self.singleton_class.send(:define_method, "get_bits_set_for_#{column_name}") { |bit_value|
        set_bits = get_set_bits(bit_value)
        values_map = send("inverted_values_for_#{column_name}")
        set_bits.map{|value| values_map[value]}
      }

      self.singleton_class.send(:define_method, "generate_bit_value_for_#{column_name}") { |keys|
        values_map = send("values_for_#{column_name}")
        keys.inject(0) {|bit_value, key| bit_value |= values_map[key] }
      }

      define_method("get_bits_info_for_#{column_name}") {
        bit_value = fetch_value_from_ar_object(column_name)
        self.class.send("get_bits_info_for_#{column_name}", bit_value)
      }

      define_method("get_bits_set_for_#{column_name}") {
        bit_value = fetch_value_from_ar_object(column_name)
        self.class.send("get_bits_set_for_#{column_name}", bit_value)
      }

      define_method("unset_#{column_name}") {
        current_val = fetch_value_from_ar_object(column_name)
        final_val = current_val & 0
        self.send("#{column_name}=", final_val)
      }

      values_hash.each do |attribute, value|

        self.singleton_class.send(:define_method, attribute) {
          where("#{column_name} & #{value} > 0")
        }

        define_method("#{attribute}?") {
          value & fetch_value_from_ar_object(column_name) == value
        }

        define_method("set_#{attribute}") {
          current_val = fetch_value_from_ar_object(column_name)
          final_val = current_val | value
          self.send("#{column_name}=", final_val)
        }

        define_method("unset_#{attribute}") {
          current_val = fetch_value_from_ar_object(column_name)
          final_val = current_val & ~value
          self.send("#{column_name}=", final_val)
        }

      end

    end

  end

  class_methods do

  end

end