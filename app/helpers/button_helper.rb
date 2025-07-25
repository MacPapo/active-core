module ButtonHelper
  def delete_button_to(record, id:, text: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top", turbo_confirm: t("global.delete_dialog") })
    base_classes = "btn-delete"
    classes = safe_join([ base_classes, classes ], " ")
    build_button_prepared(
      record,
      id:,
      method: :delete,
      text:,
      icon: "delete",
      size:,
      classes:,
      turbo:,
    )
  end

  def restore_button_to(record, id:, text: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top", turbo_confirm: t("global.restore_dialog") })
    base_classes = "btn-restore"
    classes = safe_join([ base_classes, classes ], " ")
    build_button_prepared(
      record,
      id:,
      method: :patch,
      text:,
      icon: "restore",
      size:,
      classes:,
      turbo:,
    )
  end

  def edit_button_to(path, text: nil, size: 24, classes: nil)
    base_classes = "btn-edit"
    classes = safe_join([ base_classes, classes ], " ")
    build_link_prepared(
      path,
      text:,
      icon: "edit",
      size:,
      classes:
    )
  end

  def view_button_to(path, text: nil, size: 24, classes: nil)
    base_classes = "btn-view"
    classes = safe_join([ base_classes, classes ], " ")
    build_link_prepared(
      path,
      text:,
      icon: "info",
      size:,
      classes:
    )
  end

  def add_button_to(path, text: nil, icon: "add", size: 24, classes: "btn-sm")
    text_span = text.nil? ? nil : content_tag(:span, text)
    link_to path,
            class: "btn border border-secondary-subtle text-secondary bg-dark d-inline-flex align-items-center gap-1 #{classes}",
            data: { turbo_frame: "_top" } do
      icon(icon, size: size) + text_span
    end
  end

  def filter_toggle_button(id: "filter-toggle", text: t("global.filters"), icon: "filter", size: 24, classes: nil, turbo: { action: "click->filters#toggle" })
    base_classes = "btn btn-secondary text-primary border border-secondary-subtle"
    classes = safe_join([ base_classes, classes ], " ")
    build_button(
      nil,
      id:,
      method: :get,
      text:,
      icon: "filter",
      size:,
      classes:,
      turbo:
    )
  end

  def presenter_button(presenter, obj:, turbo_frame: "_top", icon_size: 16, extra_classes: "")
    link_to presenter.appropriate_path(obj),
            method: presenter.method,
            class: "btn btn-#{presenter.css_color} text-secondary border border-secondary-subtle badge rounded-pill d-inline-flex align-items-center gap-1 #{extra_classes}",
            data: { turbo_method: presenter.method, turbo_frame: turbo_frame } do
      safe_join([ icon(presenter.link_icon, size: icon_size), presenter.link_title ], " ")
    end
  end

  private

  def build_link_prepared(path, text: nil, icon: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top" })
    base_classes = "btn border border-secondary-subtle text-secondary"
    classes = safe_join([ base_classes, classes ], " ")
    build_link(
      path,
      text:,
      icon:,
      size:,
      classes:,
      turbo:
    )
  end

  def build_button_prepared(path, id:, method:, text: nil, icon: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top" })
    base_classes = "btn border border-secondary-subtle text-secondary"
    classes = safe_join([ base_classes, classes ], " ")
    build_button(
      path,
      id:,
      method:,
      text:,
      icon:,
      size:,
      classes:,
      turbo:
    )
  end

  def build_link(path, text: nil, icon: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top" })
    icon_tag = icon.nil? ? nil : icon(icon, size:)
    text_tag = text.nil? ? nil : text
    base_classes = "d-inline-flex align-items-center gap-1"
    classes = safe_join([ base_classes, classes ], " ")
    link_to path,
            class: classes,
            data: turbo do
      safe_join([ icon_tag, text_tag ], " ")
    end
  end

  def build_button(path, id:, method:, text: nil, icon: nil, size: 24, classes: nil, turbo: { turbo_frame: "_top" })
    icon_tag = icon.nil? ? nil : icon(icon, size:)
    text_tag = text.nil? ? nil : text
    base_classes = "d-inline-flex align-items-center gap-1"
    classes = safe_join([ base_classes, classes ], " ")
    button_to path,
              id:,
              method:,
              class: classes,
              data: turbo do
      safe_join([ icon_tag, text_tag ], " ")
    end
  end
end
