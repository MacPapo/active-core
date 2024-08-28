# frozen_string_literal: true

# Subscription Helper
module SubscriptionsHelper
  def humanize_timestamp(timestamp)
    distance_of_time_in_words_to_now timestamp
  end
end
