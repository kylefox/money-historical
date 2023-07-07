# frozen_string_literal: true

require "money/historical"
require "rspec/its"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def today
    Time.now.utc
  end

  def yesterday
    days_ago(1)
  end

  def days_ago(days)
    today - (days * 86400)
  end

  def today_to_s
    date_to_s(today)
  end

  def yesterday_to_s
    date_to_s(yesterday)
  end

  def date_to_s(date)
    date.strftime("%Y-%m-%d")
  end
end
