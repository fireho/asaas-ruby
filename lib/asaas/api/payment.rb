module Asaas
  module Api
    class Payment < Asaas::Api::Base

      def initialize(token, api_version)
        super(token, api_version, '/payments')
      end

      # Fetches the PIX QR Code for a given payment ID.
      # @param payment_id [String] The ID of the payment.
      # @return [Asaas::Entity::PaymentPix, Asaas::Entity::Error] The PIX QR code entity or an error entity.
      def pix_qr_code(payment_id)
        raise ArgumentError, "payment_id is required" if payment_id.nil? || payment_id.to_s.empty?

        payment_pix_api = Asaas::Api::PaymentPix.new(@token, @api_version, payment_id)
        payment_pix_api.fetch
      end

    end
  end
end