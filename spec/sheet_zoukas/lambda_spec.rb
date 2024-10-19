# rubocop:disable RSpec/ExampleLength
# frozen_string_literal: true

require 'json'
require 'sheet_zoukas'

RSpec.describe SheetZoukas::Lambda do
  let(:event_with_body) do
    { 'body' => '{ "sheet_id": "sheet_id_slug_body", "tab_name": "tab_name_slug", "range": "A1:Z200" }' }
  end

  let(:event_with_query_string_parameters) do
    { 'queryStringParameters' =>
      '{ "sheet_id": "sheet_id_slug_qsp", "tab_name": "tab_name_slug", "range": "A1:Z200" }' }
  end

  it 'has a version number' do
    expect(SheetZoukas::Lambda::VERSION).not_to be_nil
  end

  describe '.extract_payload' do
    it 'calls extract_body when only body' do
      expect(described_class.send(:extract_payload, event_with_body)).to eq(JSON.parse(event_with_body['body']))
    end

    it 'calls body when body and queryStringParameters' do
      payload_ = event_with_body.merge(event_with_query_string_parameters)
      expect(described_class.send(:extract_payload, payload_)).to eq(JSON.parse(event_with_body['body']))
    end

    it 'calls extract_query_string_parameters when only queryStringParameters' do
      expect(described_class
        .send(:extract_payload, event_with_query_string_parameters))
        .to eq(JSON.parse(event_with_query_string_parameters['queryStringParameters']))
    end

    it 'raises error when no values in body or queryStringParameters' do
      expect { described_class.send(:extract_payload, {}) }.to raise_error(SheetZoukas::Lambda::Error)
    end
  end

  describe '.lambda_handler' do
    it 'calls SheetZoukas::Lambda.lambda_handler with body' do
      allow(described_class).to receive(:call_sheet)

      described_class.lambda_handler(event: event_with_body, context: nil)

      body = JSON.parse(event_with_body['body'])

      expect(described_class).to have_received(:call_sheet).with(body['sheet_id'],
                                                                 body['tab_name'],
                                                                 body['range'])
    end

    it 'calls SheetZoukas::Lambda.lambda_handler with queryStringParameters' do
      allow(described_class).to receive(:call_sheet)

      described_class.lambda_handler(event: event_with_query_string_parameters, context: nil)

      qsp = JSON.parse(event_with_query_string_parameters['queryStringParameters'])

      expect(described_class).to have_received(:call_sheet)
        .with(qsp['sheet_id'],
              qsp['tab_name'],
              qsp['range'])
    end
  end

  describe '.extract_body' do
    it 'returns body' do
      expect(described_class.send(:extract_body, event_with_body)).to eq(JSON.parse(event_with_body['body']))
    end

    it 'returns empty hash when no body' do
      expect(described_class.send(:extract_body, event_with_query_string_parameters)).to eq('')
    end
  end

  describe '.extract_query_string_parameters' do
    it 'returns query_string_parameters' do
      expect(described_class
        .send(:extract_query_string_parameters, event_with_query_string_parameters))
        .to eq(JSON.parse(event_with_query_string_parameters['queryStringParameters']))
    end

    it 'returns empty hash when no query_string_parameters' do
      expect(described_class.send(:extract_query_string_parameters, event_with_body)).to eq('')
    end
  end

  describe '.call_sheet' do
    describe 'calls SheetZoukas::Lambda.call_sheet' do
      it 'with all parameters' do
        VCR.use_cassette('call_sheet_all') do
          data = described_class.send(:call_sheet, 'sheet_id_slug', 'tab_name_slug', 'A1:Z200')

          expect(JSON.parse(data)[0]).to eq(
            { 'Place' => 'Slice Brothers', 'Deal' => '2 slices for $5.99', 'Deal Earned' => '', 'Deal Used' => '03/30',
              'Deal Starts' => '', 'Deal Ends' => '', 'Notes' => 'no longer active', 'Money Saved' => '4.99',
              'Reward Type' => 'no longer active' }
          )
        end
      end

      it 'with all sheet_id and tab_name' do
        VCR.use_cassette('call_sheet_some') do
          data = described_class.send(:call_sheet, 'sheet_id_slug', 'tab_name_slug')

          expect(JSON.parse(data)[0]).to eq(
            { 'Place' => 'Slice Brothers', 'Deal' => '2 slices for $5.99', 'Deal Earned' => '', 'Deal Used' => '03/30',
              'Deal Starts' => '', 'Deal Ends' => '', 'Notes' => 'no longer active', 'Money Saved' => '4.99',
              'Reward Type' => 'no longer active' }
          )
        end
      end

      it 'and logs error' do
        VCR.use_cassette('call_sheet_error') do
          expect do
            described_class.send(:call_sheet, 'sheet_id_slug', 'tab_name_slug')
          end.to raise_error(Google::Apis::ClientError)
        end
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength
