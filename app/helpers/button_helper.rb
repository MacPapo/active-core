module ButtonHelper
  def delete_button_to(record, options = {})
    build_button(
      record,
      method: :delete,
      icon: options.delete(:icon) || "delete",
      btn_class: "btn-delete",
      confirm: options.delete(:confirm) || t('global.delete_dialog'),
      size: options.delete(:size)
    )
  end

  def restore_button_to(path, options = {})
    build_button(
      path,
      method: :patch,
      icon: options.delete(:icon_html) || '<i class="bi bi-recycle"></i>'.html_safe,
      btn_class: "btn-restore",
      confirm: options.delete(:confirm) || t('global.restore_dialog'),
      size: options.delete(:size)
    )
  end

  def edit_button_to(path, options = {})
    link_to path,
            class: build_btn_class("btn-edit", options.delete(:size)),
            data: { turbo_frame: "_top" } do
      icon(options.delete(:icon) || "edit")
    end
  end

  def view_button_to(path, options = {})
    link_to path,
            class: build_btn_class("btn-view", options.delete(:size)),
            data: { turbo_frame: "_top" } do
      icon(options.delete(:icon) || "info")
    end
  end

  def add_button_to(path, text: nil, icon: "add", size: 24, classes: "btn-sm")
    link_to path,
            class: "btn border border-secondary-subtle text-secondary bg-dark d-inline-flex align-items-center gap-1 #{classes}",
            data: { turbo_frame: "_top" } do
      icon(icon, size: size) + content_tag(:span, text || t('.add'))
    end
  end

  def filter_toggle_button(text = t('global.filters'), icon: 'filter', classes: '')
    tag.button(
      icon(icon) + tag.span(text),
      id: "filter-toggle",
      class: "btn btn-secondary text-primary border border-secondary-subtle d-inline-flex align-items-center gap-1 #{classes}",
      data: { action: 'click->filters#toggle' }
    )
  end

  def presenter_button(presenter, obj:, turbo_frame: "_top", icon_size: 16, extra_classes: "")
    link_to presenter.appropriate_path(obj),
            method: presenter.method,
            class: "btn btn-#{presenter.css_color} text-secondary border border-secondary-subtle badge rounded-pill d-inline-flex align-items-center gap-1 #{extra_classes}",
            data: { turbo_method: presenter.method, turbo_frame: turbo_frame } do
      safe_join([
                  icon(presenter.link_icon, size: icon_size),
                  presenter.link_title
                ], " ")
    end
  end

  private

  def build_button(path, method:, icon:, btn_class:, confirm:, size: nil)
    button_to path,
              method: method,
              class: build_btn_class(btn_class, size),
              data: { turbo_frame: "_top", turbo_confirm: confirm },
              form: { style: 'display:inline-block;' } do
      icon.is_a?(String) && icon.start_with?('<') ? icon : icon(icon)
    end
  end

  def build_btn_class(base_class, size)
    size ||= "btn-sm"
    "btn #{base_class} #{size} border border-secondary-subtle"
  end
end
