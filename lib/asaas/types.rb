Dry::Types.load_extensions(:maybe)

module Types
  include Dry::Types(default: :nominal)

  # Custom Decimal type to ensure safe Float to BigDecimal conversion.
  # This type explicitly converts Floats to Strings before creating a BigDecimal object
  # to avoid the "can't omit precision for a Float" error.
  SafeCoercibleDecimal = Types.Constructor(BigDecimal) do |value|
    begin
      # Explicitly convert all to string, as it should be
      BigDecimal(value.to_s) # For Integer, BigDecimal itself, etc.
    rescue ArgumentError, TypeError
      Dry::Types::Undefined # Let dry-types handle it as a validation error or apply default.
    end
  end
end