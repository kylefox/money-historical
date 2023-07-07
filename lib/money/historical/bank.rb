class Money
  module Historical
    class Bank < Money::Bank::VariableExchange
      def get_rate(from, to, date: nil)
        store.get_rate(from, to, date: date)
      end

      def exchange_with(from, to_currency, date: nil)
        perform_exchange(from, to_currency, date: date)[:amount]
      end

      def perform_exchange(from, to_currency, date: nil)
        # There's some funky stuff the money gem does when performing the conversion.
        # Instead of re-implementing that logic, what we do is:
        #   (1) Create a temporary in-memory bank
        #   (2) Add the rate from the date we want using the built-in `#add_rate` method
        #   (3) Delegate the calculation to the in-memory bank (`#exchange_with`)
        # We then return both the converted amount and the rate that was used.
        official_bank = Money::Bank::VariableExchange.new
        rate = get_rate(from.currency, to_currency, date: date)
        official_bank.add_rate(from.currency, to_currency, rate)

        {rate: rate, amount: official_bank.exchange_with(from, to_currency)}
      end
    end
  end
end
