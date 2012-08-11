# encoding: utf-8

module SetupConfiguration

  # The <code>BinaryCodedValues</code> mixin provides common methods for transforming meaningful values
  # in binary coded values - and vice versa.
  # The class must provide a method <code>values</code>, which
  # delivers a hash with the values and its numbers.
  module BinaryCodedValues

    # Gets the number (or: numerical value) of the given value.
    def number(value)
      if values.has_key?(value)
        values[value]
      else
        raise ArgumentError.new("'#{value}' is not a valid option. Valid values: #{self.pretty}")
      end
    end

    # Gets the value to the given number.
    def value(number)
      # 60.to_s(2).chars.to_a.reverse.each_with_index { |s,i| puts s; puts i}
      result=[]
      unless number.eql?(0) then
        Fixnum.induced_from(number).to_s(2).chars.to_a.reverse.each_with_index do |value, index|
          if value.eql?("1")
            role = values.index(2**index)
            result << role if role
          end
        end
      end
      result
    end

    def pretty
      s = ""
      PP.pp(values.keys, s)
      s
    end
  end

end
