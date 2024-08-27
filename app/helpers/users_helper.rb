# frozen_string_literal: true

# Users Helper
module UsersHelper
  def num_to_human_days(num)
    I18n.t('datetime.distance_in_words.x_days', count: num)
  end

  def num_to_human_years(num)
    I18n.t('datetime.distance_in_words.x_years', count: num)
  end
end
