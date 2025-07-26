# frozen_string_literal: true

# Users Helper
module UsersHelper
  def attribute_to_string(model, attr)
    return "empty" if model.blank? || attr.blank?

    model_class = model.class
    model_class.human_attribute_name(attr)
  end

  def model_to_string(model, count = 1)
    return "empty" if model.blank?

    model.model_name.human(count:)
  end

  def num_to_human_days(num)
    I18n.t("datetime.distance_in_words.x_days", count: num)
  end

  def num_to_human_years(num)
    I18n.t("datetime.distance_in_words.x_years", count: num)
  end

  def phone_to_string(phone)
    return I18n.t("empty") if phone.blank?

    Phonelib.parse(phone).full_international
  end
end
