# rubocop:disable RSpec/ExampleLength
# frozen_string_literal: true

require 'json'
require 'sheet_zoukas'

RSpec.describe SheetZoukas::Lambda do
  let(:event) do
    { sheet_id: 'sheet_id_slug', tab_name: 'tab_name_slug', range: 'A1:Z200' }
  end

  it 'has a version number' do
    expect(SheetZoukas::Lambda::VERSION).not_to be_nil
  end

  describe '.lambda_handler' do
    it 'calls SheetZoukas::Lambda.lambda_handler' do
      allow(described_class).to receive(:call_sheet)

      described_class.lambda_handler(event: event, context: nil)

      expect(described_class).to have_received(:call_sheet).with(event[:sheet_id], event[:tab_name], event[:range])
    end
  end

  describe '.call_sheet' do
    it 'calls SheetZoukas::Lambda.call_sheet with all parameters' do
      VCR.use_cassette('call_sheet_all') do
        data = described_class.send(:call_sheet, event[:sheet_id], event[:tab_name], event[:range])

        expect(JSON.parse(data)[0]).to eq(
          { 'Place' => 'Slice Brothers', 'Deal' => '2 slices for $5.99', 'Deal Earned' => '', 'Deal Used' => '03/30',
            'Deal Starts' => '', 'Deal Ends' => '', 'Notes' => 'no longer active', 'Money Saved' => '4.99',
            'Reward Type' => 'no longer active' }
        )
      end
    end

    it 'calls SheetZoukas::Lambda.call_sheet with all sheet_id and tab_name' do
      VCR.use_cassette('call_sheet_some') do
        data = described_class.send(:call_sheet, event[:sheet_id], event[:tab_name])

        expect(JSON.parse(data)[0]).to eq(
          { 'Place' => 'Slice Brothers', 'Deal' => '2 slices for $5.99', 'Deal Earned' => '', 'Deal Used' => '03/30',
            'Deal Starts' => '', 'Deal Ends' => '', 'Notes' => 'no longer active', 'Money Saved' => '4.99',
            'Reward Type' => 'no longer active' }
        )
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength
