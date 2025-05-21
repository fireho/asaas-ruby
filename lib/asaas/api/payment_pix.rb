module Asaas
  module Api
    class PaymentPix < Asaas::Api::Base

      def initialize(token, api_version, pid)
        super(token, api_version, "/payments/#{pid}/pixQrCode")
      end

      # Method to fetch the QR Code data
      # @return [Asaas::Entity::PaymentPix, Asaas::Entity::Error] The PIX QR code entity or an error entity.
      def fetch
        request(:get) # Calls Base#request with method GET, empty params, nil body
        parse_response  # Calls Base#parse_response, which will call our overridden response_success
      end

      protected

      # Override response_success to handle the specific structure of pixQrCode response
      def response_success
        hash = JSON.parse(@response.body)
        Asaas::Entity::PaymentPix.new(hash)
      end
    end
  end
end