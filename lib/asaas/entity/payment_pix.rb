module Asaas
  module Entity
    class PaymentPix
      include Virtus.model

      attribute :encodedImage, String
      attribute :payload, String
      attribute :expirationDate, String
    end
  end
end
