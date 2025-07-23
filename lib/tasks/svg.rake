namespace :svg do
  desc "Normalize SVG icons in app/assets/images/icons/"
  task normalize: :environment do
    require "nokogiri"

    Dir.glob(Rails.root.join("app/assets/images/icons/*.svg")).each do |file_path|
      puts "Normalizing #{file_path}"

      svg = File.read(file_path)
      doc = Nokogiri::XML(svg)

      svg_node = doc.at_css("svg")
      next unless svg_node

      # Rimuovi attributi che hardcodano lo stile
      %w[width height fill stroke].each { |attr| svg_node.remove_attribute(attr) }

      # Imposta fill come currentColor per ereditarlo dal CSS
      svg_node["fill"] = "currentColor"

      # Rimuovi titoli, commenti, metadata
      doc.xpath("//comment()").remove
      doc.css("title, desc, metadata").each(&:remove)

      # Rimuovi id per evitare conflitti JS
      doc.css("*[id]").each { |el| el.remove_attribute("id") }

      # Sovrascrivi il file
      File.write(file_path, doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
    end
  end
end
