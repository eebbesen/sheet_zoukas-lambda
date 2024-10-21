# frozen_string_literal: true

require 'spec_helper'
require 'sheet_zoukas/lambda/logger'

RSpec.describe SheetZoukas::Lambda::Logger do
  describe '.log' do
    context 'when ZOUKAS_LOG_LEVEL set to DEBUG' do
      before do
        allow(ENV).to receive(:fetch).with('ZOUKAS_LOG_LEVEL', 'ERROR').and_return('DEBUG')
      end

      it 'logs messages at DEBUG level' do
        expect { described_class.log('DEBUG', 'This is a debug message') }
          .to output("DEBUG: This is a debug message\n").to_stdout
      end

      it 'logs messages at ERROR level' do
        expect { described_class.log('ERROR', 'This is a debug message') }
          .to output("ERROR: This is a debug message\n").to_stdout
      end

      it 'logs messages at INFO level' do
        expect { described_class.log('INFO', 'This is a debug message') }
          .to output("INFO: This is a debug message\n").to_stdout
      end
    end

    context 'when ZOUKAS_LOG_LEVEL set to INFO' do
      before do
        allow(ENV).to receive(:fetch).with('ZOUKAS_LOG_LEVEL', 'ERROR').and_return('INFO')
      end

      it 'logs messages at DEBUG level' do
        expect { described_class.log('DEBUG', 'This is a debug message') }
          .not_to output("DEBUG: This is a debug message\n").to_stdout
      end

      it 'logs messages at ERROR level' do
        expect { described_class.log('ERROR', 'This is a debug message') }
          .not_to output("ERROR: This is a debug message\n").to_stdout
      end

      it 'logs messages at INFO level' do
        expect { described_class.log('INFO', 'This is a debug message') }
          .to output("INFO: This is a debug message\n").to_stdout
      end
    end

    context 'when ZOUKAS_LOG_LEVEL not set' do
      before do
        allow(ENV).to receive(:fetch).with('ZOUKAS_LOG_LEVEL', 'ERROR').and_return('ERROR')
      end

      it 'logs messages at DEBUG level' do
        expect { described_class.log('DEBUG', 'This is a debug message') }
          .not_to output("DEBUG: This is a debug message\n").to_stdout
      end

      it 'logs messages at ERROR level' do
        expect { described_class.log('ERROR', 'This is a debug message') }
          .to output("ERROR: This is a debug message\n").to_stdout
      end

      it 'logs messages at INFO level' do
        expect { described_class.log('INFO', 'This is a debug message') }
          .not_to output("INFO: This is a debug message\n").to_stdout
      end
    end
  end
end
