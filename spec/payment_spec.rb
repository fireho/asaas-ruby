require 'spec_helper'

RSpec.describe Asaas::Payment do
  let(:api_token) { 'test_api_token_for_payment_spec' }
  let(:asaas_client) { Asaas::Client.new(api_token) }
  let(:base_url) { Asaas::Configuration.get_endpoint(3) } # Assumes API v3 for payments
  let(:customer_id) { 'cus_000000000001' }

  let(:request_headers) do
    {
      'Access-Token' => api_token,
      'Content-Type' => 'application/json'
    }
  end

  let(:default_payment_response_attributes) do
    {
      object: 'payment',
      id: 'pay_123456789012',
      customer: customer_id,
      billingType: 'PIX',
      value: 10.0,
      dueDate: '2024-12-31',
      description: 'Test Payment from API', # Assuming API might return its own description or echo
      status: 'PENDING'
    }
  end

  describe '.create' do
    let(:payment_attributes_for_creation) do
      {
        customer: customer_id,
        billingType: 'PIX',
        value: 10.00, # Will be coerced to BigDecimal by model, then to float in JSON
        dueDate: '2024-12-31',
        description: 'Test Payment for creation'
      }
    end

    it 'creates a payment successfully with basic attributes' do
      # The model will convert value to BigDecimal. to_h.to_json will make it a float.
      expected_request_json_body = payment_attributes_for_creation.dup
      expected_request_json_body[:value] = 10.0 # How it should look in JSON

      stub_request(:post, "#{base_url}/payments")
        .with(
          body: expected_request_json_body.to_json,
          headers: request_headers
        )
        .to_return(status: 200, body: default_payment_response_attributes.to_json, headers: { 'Content-Type' => 'application/json' })

      payment_model = Asaas::Payment.new(payment_attributes_for_creation)
      created_payment = asaas_client.payments.create(payment_model)

      expect(created_payment).to be_a(Asaas::Payment)
      expect(created_payment.id).to eq('pay_123456789012')
      expect(created_payment.value).to eq(BigDecimal('10.0')) # Model stores as BigDecimal
      expect(created_payment.billingType).to eq('PIX')
      expect(created_payment.description).to eq('Test Payment from API') # From mocked response
      expect(created_payment.customer).to eq(customer_id)
    end

    shared_examples 'value coercion for payment creation' do |input_value, expected_json_value_in_request|
      it "handles value as #{input_value.class} (input: #{input_value}), sending #{expected_json_value_in_request} in JSON" do
        attributes_for_model = payment_attributes_for_creation.merge(value: input_value)

        # This is what the JSON body of the POST request should look like
        expected_request_body_hash = payment_attributes_for_creation.merge(value: expected_json_value_in_request)

        response_payload = default_payment_response_attributes.merge(value: expected_json_value_in_request).to_json

        stub_request(:post, "#{base_url}/payments")
          .with(
            body: expected_request_body_hash.to_json,
            headers: request_headers
          )
          .to_return(status: 200, body: response_payload, headers: { 'Content-Type' => 'application/json' })

        payment_model = Asaas::Payment.new(attributes_for_model)
        created_payment = asaas_client.payments.create(payment_model)

        expect(created_payment).to be_a(Asaas::Payment)
        # The model attribute 'value' will be a BigDecimal after creation from response
        expect(created_payment.value).to eq(BigDecimal(expected_json_value_in_request.to_s))
      end
    end

    context 'when value is an Integer' do
      include_examples 'value coercion for payment creation', 100, 100.0
    end

    context 'when value is a Float' do
      include_examples 'value coercion for payment creation', 123.454, 123.454
    end

    context 'when value is a String representing a number' do
      include_examples 'value coercion for payment creation', '1250.75', 1250.75
    end

    context 'when value is a BigDecimal' do
      include_examples 'value coercion for payment creation', BigDecimal('55.99'), 55.99
    end

    context 'when value is a String like "50.00" (with trailing zeros)' do
      include_examples 'value coercion for payment creation', '50.00', 50.0
    end
  end

  describe '#pix_qr_code' do
    let(:payment_id) { 'pay_pix_valid123' }
    let(:pix_qr_code_response_body) { { encodedImage: 'base64...', payload: 'pixpayload', expirationDate: '2025-01-01T00:00:00Z' }.to_json }

    it 'fetches the PIX QR code successfully' do
      stub_request(:get, "#{base_url}/payments/#{payment_id}/pixQrCode").with(headers: request_headers)
        .to_return(status: 200, body: pix_qr_code_response_body, headers: { 'Content-Type' => 'application/json' })

      qr_code_data = asaas_client.payments.pix_qr_code(payment_id)
      expect(qr_code_data).to be_a(Asaas::Entity::PaymentPix)
      expect(qr_code_data.encodedImage).to eq('base64...')
      expect(qr_code_data.payload).to eq('pixpayload')
    end

    it 'raises ArgumentError if payment_id is nil' do
      expect { asaas_client.payments.pix_qr_code(nil) }.to raise_error(ArgumentError, "payment_id is required")
    end

    it 'returns Asaas::Entity::Error when API call fails for QR code' do
      error_response = { errors: [{ code: 'not_found', description: 'Payment not found.' }] }.to_json
      stub_request(:get, "#{base_url}/payments/#{payment_id}/pixQrCode").with(headers: request_headers)
        .to_return(status: 404, body: error_response, headers: { 'Content-Type' => 'application/json' })

      result = asaas_client.payments.pix_qr_code(payment_id)
      expect(result).to be_a(Asaas::Entity::Error)
      expect(result.errors.first.code).to eq('not_found')
    end
  end
end