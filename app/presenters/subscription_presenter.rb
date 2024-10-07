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
      renew_subscription_path(@subscription, user_id: user&.id)
    when :deleted
      restore_subscription_path(@subscription)
    else
      new_subscription_path(user_id: user&.id)
    end
  end

  def method
    return :patch if subscription_handler == :deleted

    :get
  end

  def link_title
    sname = @subscription.activity&.name
    oname = @subscription.open_subscription&.activity&.name

    if @subscription.open?
      "#{sname} + #{oname}"
    else
      sname
    end
  end

  def status_title
    return I18n.t('global.restore') if subscription_handler == :deleted
    return @subscription.humanize_status unless subscription_handler == :empty

    I18n.t('empty')
  end

  def link_icon
    case subscription_handler
    when :active
      'me-2 text-secondary bi bi-eye-fill'
    when :inactive
      'me-2 text-secondary bi bi-credit-card'
    when :expired
      'me-2 text-secondary bi bi-arrow-clockwise'
    when :deleted
      'me-1 text-secondary bi bi-recycle'
    else
      'me-2 text-secondary bi bi-plus-circle-fill'
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
    when :deleted
      'restore'
    else
      'danger'
    end
  end

  private

  def subscription_handler
    return :deleted if @subscription&.discarded?

    return :active if @subscription&.active?
    return :inactive if @subscription&.inactive?
    return :expired if @subscription&.expired?

    :empty
  end
end
