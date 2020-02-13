require 'spec_helper'

describe FastJsonapi do
  describe '.call_proc' do
    context 'with a Proc' do
      context 'with no parameters' do
        let(:function) { proc { 42 } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(42)
        end
      end

      context 'with a single parameter' do
        let(:function) { proc { |a| 42 + a } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(43)
        end
      end

      context 'with multiple parameters' do
        let(:function) { proc { |a, b| 42 + a + b } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(45)
        end
      end

      context 'with default parameters' do
        let(:function) { proc { |a = 0, b = 0| 42 + a + b } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(45)
        end
      end
    end

    context 'with a lambda' do
      context 'with no parameters' do
        let(:function) { -> { 42 } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(42)
        end
      end

      context 'with a single parameter' do
        let(:function) { ->(a) { 42 + a } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(43)
        end
      end

      context 'with multiple parameters' do
        let(:function) { ->(a, b) { 42 + a + b } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(45)
        end
      end

      context 'with default parameters' do
        let(:function) { ->(a = 0, b = 0) { 42 + a + b } }

        it 'calls the proc' do
          expect(FastJsonapi.call_proc(function, 1, 2)).to eq(45)
        end
      end
    end
  end
end
