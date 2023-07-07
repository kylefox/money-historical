class Money
  module Historical
    module RatesStore
      class MemoryStore < Base
        attr_reader :rates

        def initialize(*args, **kwargs)
          super(*args, **kwargs)
          @rates = {}
        end

        def get_rates(date: nil)
          @rates[format_date(date)] || {}
        end

        def add_rates(rates, date: nil)
          @rates[format_date(date)] = rates
        end
      end
    end
  end
end
