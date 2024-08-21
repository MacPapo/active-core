# frozen_string_literal: true

# Subscription Presenter
class SubscriptionPresenter
  include Rails.application.routes.url_helpers

  def initialize(subscription)
    @subscription = subscription
  end

  def appropriate_path(user)
    case subscription_handler
    when :active
      subscription_path(@subscription)
    when :inactive
      new_payment_path(payable_type: 'Subscription', payable_id: @subscription.id)
    when :expired
      edit_subscription_path(@subscription, user_id: user&.id)
    else
      new_subscription_path(user_id: user&.id)
    end
  end

  def link_title
    sname = @subscription.activity&.name
    oname = @subscription.open_subscription&.activity&.name

    if @subscription.open?
      "#{sname.titleize} + #{oname.titleize}"
    else
      sname.titleize
    end
  end

  def link_icon
    case subscription_handler
    when :active
      'me-2 bi bi-eye'
    when :inactive
      'me-2 bi bi-credit-card'
    when :expired
      'me-2 bi bi-arrow-clockwise'
    else
      'me-2 bi bi-plus-lg'
    end
  end

  def css_color
    case subscription_handler
    when :active
      'success'
    when :inactive
      'info'
    when :expired
      'warning'
    else
      'danger'
    end
  end

  private

  def subscription_handler
    return :empty unless @subscription

    return :active if @subscription.active?
    return :inactive if @subscription.inactive?
    return :expired if @subscription.expired?

    :empty
  end
end
