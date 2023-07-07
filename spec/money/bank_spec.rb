# frozen_string_literal: true

RSpec.describe Money::Historical::Bank do
  subject(:bank) { described_class.new(Money::Historical::RatesStore::MemoryStore.new(base_currency: "USD")) }

  before do
    bank.store.add_rates({"CAD" => 1.32, "EUR" => 0.91})
    bank.store.add_rates({"CAD" => 1.33, "EUR" => 0.92}, date: yesterday)
  end

  describe "#get_rate" do
    context "when date is not provided" do
      it "returns today's rates" do
        expect(bank.get_rate(:usd, :cad)).to eq(1.32)
      end
    end

    context "when date is provided" do
      it "returns that date's rates" do
        expect(bank.get_rate(:usd, :cad, date: yesterday)).to eq(1.33)
      end
    end
  end

  describe "#perform_exchange" do
    it "returns the rate and converted amount" do
      expect(
        bank.perform_exchange(Money.new(100_00, :USD), :CAD)
      ).to eq(
        {amount: Money.new(132_00, :CAD), rate: 1.32}
      )
    end
  end

  describe "#exchange_with" do
    it "returns the converted amount" do
      expect(
        bank.exchange_with(Money.new(100_00, :USD), :CAD, date: yesterday)
      ).to eq(
        Money.new(133_00, :CAD)
      )
    end
  end

  context "when rate is missing" do
    it "raises an error" do
      expect { bank.get_rate("USD", "GBP") }.to raise_error(Money::Historical::RatesStore::MissingRateError, "store has no rate for GBP")
    end
  end

  describe "Money#exchange_to" do
    before { Money.default_bank = bank }

    it "performs the exchange (both base)" do
      expect(Money.new(100_00, "USD").exchange_to("USD")).to eq Money.new(100_00, "USD")
    end

    it "performs the exchange (from base)" do
      expect(Money.new(100_00, "USD").exchange_to("CAD")).to eq Money.new(132_00, "CAD")
    end

    it "performs the exchange (to base)" do
      expect(Money.new(100_00, "CAD").exchange_to("USD")).to eq Money.new(75_76, "USD")
    end
  end
end
