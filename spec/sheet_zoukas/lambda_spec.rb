# rubocop:disable RSpec/ExampleLength
# frozen_string_literal: true

require 'json'
require 'sheet_zoukas'

RSpec.describe SheetZoukas::Lambda do
  before { clear_defaults }

  let(:event_with_body) do
    { 'body' => '{ "sheet_id": "sheet_id_slug_body", "tab_name": "tab_name_slug", "range": "A1:Z200" }' }
  end

  let(:event_with_query_string_parameters) do
    { 'queryStringParameters' =>
      { sheet_id: 'sheet_id_slug_qsp', tab_name: 'tab_name_slug', range: 'A1:Z200' } }
  end

  it 'has a version number' do
    expect(SheetZoukas::Lambda::VERSION).not_to be_nil
  end

  describe 'merge_defaults' do
    describe 'without defaults set' do
      it 'merges with defaults when path is defaults' do
        body = JSON.parse(event_with_body['body']).except('tab_name')

        expect(described_class.send(:merge_defaults, '/defaults', body)).to eq(body)
      end
    end

    describe 'with defaults set' do
      before { set_defaults }

      it 'does not merge defaults when path is empty' do
        body = JSON.parse(event_with_body['body']).except('sheet_id')

        expect(described_class.send(:merge_defaults, '/', body)).to eq(body)
      end

      it 'does not merge defaults when path set to something other than defaults' do
        body = JSON.parse(event_with_body['body']).except('sheet_id')

        expect(described_class.send(:merge_defaults, '/humegatech', body)).to eq(body)
      end

      describe 'path is defaults' do # rubocop:disable RSpec/NestedGroups
        it 'does not merge defaults when all values in body' do
          body = JSON.parse(event_with_body['body'])

          expect(described_class.send(:merge_defaults, '/humegatech', body)).to eq(body)
        end

        it 'merges with defaults' do
          body = JSON.parse(event_with_body['body']).except('sheet_id')

          expect(described_class
            .send(:merge_defaults, '/defaults', body))
            .to eq(body.merge({ 'sheet_id' => ENV.fetch('DEFAULT_SHEET_ID', '') }))
        end

        it 'returns defaults when nothing passed' do
          expect(described_class.send(:merge_defaults, '/defaults', {})).to eq(
            { 'sheet_id' => ENV.fetch('DEFAULT_SHEET_ID', ''),
              'tab_name' => ENV.fetch('DEFAULT_TAB_NAME', ''),
              'range' => ENV.fetch('DEFAULT_RANGE', '') }
          )
        end
      end
    end
  end

  describe '.extract_payload' do
    it 'uses defaults when no values in body or queryStringParameters' do
      set_defaults

      expect(described_class
      .send(:extract_payload,
            { 'rawPath' => '/defaults' })).to eq({ 'sheet_id' => ENV.fetch('DEFAULT_SHEET_ID', ''),
                                                   'tab_name' => ENV.fetch('DEFAULT_TAB_NAME', ''),
                                                   'range' => ENV.fetch('DEFAULT_RANGE', '') })
    end

    it 'calls extract_body when only body' do
      expect(described_class.send(:extract_payload, event_with_body)).to eq(JSON.parse(event_with_body['body']))
    end

    it 'calls extract_body when body and queryStringParameters' do
      payload_ = event_with_body.merge(event_with_query_string_parameters)
      expect(described_class.send(:extract_payload, payload_)).to eq(JSON.parse(event_with_body['body']))
    end

    it 'calls extract_query_string_parameters when only queryStringParameters' do
      expect(described_class
        .send(:extract_payload, event_with_query_string_parameters))
        .to eq(event_with_query_string_parameters['queryStringParameters'])
    end

    it 'returns empty hash when not defaults path and no values in body or queryStringParameters' do
      expect(described_class.send(:extract_payload, {})).to eq({})
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

      qsp = event_with_query_string_parameters['queryStringParameters']
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
      expect(described_class.send(:extract_body, event_with_query_string_parameters)).to be_nil
    end
  end

  describe '.extract_query_string_parameters' do
    it 'returns query_string_parameters' do
      expect(described_class
        .send(:extract_query_string_parameters, event_with_query_string_parameters))
        .to eq(event_with_query_string_parameters['queryStringParameters'])
    end

    it 'returns empty hash when no query_string_parameters' do
      expect(described_class.send(:extract_query_string_parameters, event_with_body)).to be_nil
    end
  end

  describe '.validate_payload' do
    it 'returns true when sheet_id and tab_name' do
      expect { described_class.send(:validate_payload, JSON.parse(event_with_body['body'])) }.not_to raise_error
    end

    it 'raises when empty sheet_id' do
      body = JSON.parse(event_with_body['body']).merge('sheet_id' => '')

      expect { described_class.send(:validate_payload, body) }
        .to raise_error(SheetZoukas::Lambda::InvalidArgumentError, '')
    end

    it 'raises when empty tab_name' do
      expect do
        described_class.send(:validate_payload, { 'sheet_id' => 'sheet_id_slug', 'tab_name' => '' })
      end.to raise_error(SheetZoukas::Lambda::InvalidArgumentError, '')
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

      it 'returns JSON describing client error' do
        expected_error = {
          statusCode: 400,
          body: { error: "google rejected sheet_id and/or tab_name\nInvalid request (Google::Apis::ClientError)" }
        }.to_json
        VCR.use_cassette('call_sheet_error') do
          expect(described_class.send(:call_sheet, 'sheet_id_slug', 'tab_name_slug')).to eq(expected_error)
        end
      end

      it 'calls error_handler 403 with auth error' do
        expected_error = {
          statusCode: 403,
          body: { error: "server failed to authenticate with google\nSignet::AuthorizationError" }
        }.to_json
        allow(SheetZoukas)
          .to receive(:retrieve_sheet_json)
          .and_raise(Signet::AuthorizationError, '')

        expect(described_class.send(:call_sheet, 'sheet_id_slug', 'tab_name_slug')).to eq(expected_error)
      end
    end

    describe 'defaults' do
      it 'does not return key when empty value' do
        expect(described_class.send(:defaults)).to eq({})
      end

      it 'returns defaults' do
        set_defaults

        expect(described_class.send(:defaults)).to eq(
          { 'sheet_id' => ENV.fetch('DEFAULT_SHEET_ID', ''),
            'tab_name' => ENV.fetch('DEFAULT_TAB_NAME', ''),
            'range' => ENV.fetch('DEFAULT_RANGE', '') }
        )
      end
    end
  end
end

private

def set_defaults
  ENV.store('DEFAULT_SHEET_ID', 'default_sheet_id')
  ENV.store('DEFAULT_TAB_NAME', 'default_tab_name')
  ENV.store('DEFAULT_RANGE', 'default_range')
end

def clear_defaults
  ENV.delete('DEFAULT_SHEET_ID')
  ENV.delete('DEFAULT_TAB_NAME')
  ENV.delete('DEFAULT_RANGE')
end

# rubocop:enable RSpec/ExampleLength
