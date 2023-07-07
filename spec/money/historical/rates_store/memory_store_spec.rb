# frozen_string_literal: true

RSpec.describe Money::Historical::RatesStore::MemoryStore do
  subject(:store) { described_class.new }

  its(:rates) { is_expected.to eq({}) }

  before { Money.default_currency = "USD" }

  describe "#base_currency" do
    subject { store.base_currency }

    it { is_expected.to eq Money.default_currency }

    context "when provided" do
      let(:store) { described_class.new(base_currency: "CAD") }

      it { is_expected.to eq Money::Currency.new("CAD") }
    end
  end

  describe "#add_rates" do
    context "without a date" do
      before { store.add_rates({"CAD" => 1.32, "EUR" => 0.91}) }

      its(:rates) { is_expected.to eq({today_to_s => {"CAD" => 1.32, "EUR" => 0.91}}) }
    end

    context "with a date as a Time" do
      before { store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday) }

      its(:rates) { is_expected.to eq({yesterday_to_s => {"CAD" => 1.33, "EUR" => 0.92}}) }
    end

    context "with a date as a String" do
      before { store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday_to_s) }

      its(:rates) { is_expected.to eq({yesterday_to_s => {"CAD" => 1.33, "EUR" => 0.92}}) }
    end

    context "invoked multiple times" do
      before do
        store.add_rates({"CAD" => 1.32, "EUR" => 0.91})
        store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday)
      end

      its(:rates) do
        is_expected.to eq({
          today_to_s => {"CAD" => 1.32, "EUR" => 0.91},
          yesterday_to_s => {"CAD" => 1.33, "EUR" => 0.92}
        })
      end
    end
  end

  describe "#get_rates" do
    context "when rates are blank" do
      context "without a date" do
        its(:get_rates) { is_expected.to eq({}) }
      end

      context "with a date as a Time" do
        it { expect(store.get_rates(date: yesterday)).to eq({}) }
      end

      context "with a date as a String" do
        it { expect(store.get_rates(date: yesterday_to_s)).to eq({}) }
      end
    end

    context "when rates are present" do
      before do
        store.add_rates({"CAD" => 1.32, "EUR" => 0.91})
        store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday)
      end

      context "without a date" do
        it "returns today's rates" do
          expect(store.get_rates).to eq({"CAD" => 1.32, "EUR" => 0.91})
        end
      end

      context "with a date as a Time" do
        it "returns that date's rates" do
          expect(store.get_rates(date: yesterday)).to eq({"CAD" => 1.33, "EUR" => 0.92})
        end
      end

      context "with a date as a String" do
        it "returns that date's rates" do
          expect(store.get_rates(date: yesterday_to_s)).to eq({"CAD" => 1.33, "EUR" => 0.92})
        end
      end
    end
  end

  describe "#get_rate" do
    before do
      store.add_rates({"CAD" => 1.32, "EUR" => 0.91})
      store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday)
    end

    let(:from) { store.base_currency }
    let(:to) { store.base_currency }

    context "when no date is provided" do
      subject { store.get_rate(from, to) }

      context "base currency to base currency" do
        it { is_expected.to eq(1.0) }
      end

      context "base currency to non-base currency" do
        let(:to) { "CAD" }
        it { is_expected.to eq(1.32) }
      end

      context "non-base currency base currency" do
        let(:from) { "CAD" }
        it { is_expected.to eq(0.7575757575757576) }
      end

      context "non-base currency to a different non-base currency" do
        let(:from) { "EUR" }
        let(:to) { "CAD" }
        it { is_expected.to eq(1.4505494505494505) }
      end

      context "non-base currency to the same non-base currency" do
        let(:from) { "EUR" }
        let(:to) { "EUR" }
        it { is_expected.to eq(1.0) }
      end

      context "rate doesn't exist" do
        let(:to) { "BTC" }
        it "raises an error" do
          expect { subject }.to raise_error(Money::Historical::RatesStore::MissingRateError, "store has no rate for BTC")
        end
      end
    end

    context "when a date is provided" do
      subject { store.get_rate(from, to, date: yesterday) }

      context "base currency to base currency" do
        it { is_expected.to eq(1.0) }
      end

      context "base currency to non-base currency" do
        let(:to) { "CAD" }
        it { is_expected.to eq(1.33) }
      end

      context "non-base currency base currency" do
        let(:from) { "CAD" }
        it { is_expected.to eq(0.7518796992481203) }
      end

      context "non-base currency to a different non-base currency" do
        let(:from) { "EUR" }
        let(:to) { "CAD" }
        it { is_expected.to eq(1.4456521739130435) }
      end

      context "non-base currency to the same non-base currency" do
        let(:from) { "EUR" }
        let(:to) { "EUR" }
        it { is_expected.to eq(1.0) }
      end
    end
  end
end
