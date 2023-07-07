class Money
  module Historical
    module RatesStore
      class MissingRateError < StandardError; end

      class Base
        attr_reader :base_currency

        def initialize(base_currency: nil)
          @base_currency = Money::Currency.wrap(base_currency || Money.default_currency)
        end

        def get_rate(iso_from, iso_to, date: nil)
          # Ensure both `iso_from` and `iso_to` are instances of Money::Currency.
          iso_from = Money::Currency.wrap(iso_from)
          iso_to = Money::Currency.wrap(iso_to)

          return 1.0 if iso_from == iso_to

          rates = get_rates(date: date)

          from = get_rate_or_error(rates, iso_from)
          to = get_rate_or_error(rates, iso_to)

          if iso_from == base_currency  # ex: USD → CAD
            to
          elsif iso_to == base_currency # ex: CAD → USD
            1.0 / from
          else
            # CAD → EUR
            # Find the CAD to USD rate ["CAD"] → 1.32
            # Find the EUR to USD rate ["EUR"] → 0.9198
            # 100 CAD → 69.47 EUR
            to / from
          end
        end

        def get_rates(date: nil)
          raise NotImplementedError, "Subclasses must implement #get_rates"
        end

        def today
          Time.now.utc
        end

        def format_date(date)
          return date if date.is_a?(String)

          date = today if date.nil?
          date.strftime("%Y-%m-%d")
        end

        def get_rate_or_error(rates, currency)
          return 1.0 if currency == base_currency

          rate = rates[currency.iso_code]

          if rate.nil?
            raise MissingRateError, "store has no rate for #{currency.iso_code}"
          else
            rate.to_f
          end
        end
      end
    end
  end
end
