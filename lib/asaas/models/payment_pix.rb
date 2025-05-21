module Asaas
  class PaymentPix < Model

    attribute :encodedImage,   Types::Coercible::String.optional.default(nil) # Imagem do QrCode em base64
    attribute :payload,        Types::Coercible::String                             # Copia e Cola do QrCode
    attribute :expirationDate, Types::Coercible::String.optional.default(nil)
  end
end
