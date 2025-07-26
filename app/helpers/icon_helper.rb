module IconHelper
  def icon(name, size: 24, **options)
    filename = Rails.root.join("app/assets/images/icons/#{name}.svg")
    return "(missing icon: #{name})" unless File.exist?(filename)

    svg = File.read(filename)
    doc = Nokogiri::HTML::DocumentFragment.parse(svg)
    svg_element = doc.at_css("svg")
    return "(invalid svg)" unless svg_element

    # Merge class
    if options[:class]
      existing_class = svg_element["class"]
      svg_element["class"] = [ existing_class, options.delete(:class) ].compact.join(" ")
    end

    # Set default size if not provided explicitly
    svg_element["width"]  ||= size.to_s
    svg_element["height"] ||= size.to_s

    # Apply remaining attributes
    options.each do |key, value|
      if key == :data
        value.each { |data_key, data_val| svg_element["data-#{data_key}"] = data_val }
      else
        html_attr = key.to_s.tr("_", "-")
        svg_element[html_attr] = value
      end
    end

    svg_element.to_html.html_safe
  end
end
