# frozen_string_literal: true

desc "import Manitoba checklist"
task mb_checklist: :environment do
  require "open-uri"

  URL = "http://avibase.bsc-eoc.org/checklist.jsp?lang=EN&p2=1&list=clements&synlang=&region=CAmb&version=text&lifelist=&highlight=0"

  mb = Locus.find_by_slug("manitoba")

  doc = Nokogiri::HTML(open(URL), nil, "utf-8")

  doc.css("tr.highlight1").to_a.map do |node|
    name_sci = node.css("td[2]").text
    comment = node.css("td[3]").text

    puts name_sci

    sp = Species.find_by_name_sci(name_sci)

    ls = mb.local_species.find_or_create_by!(species_id: sp.id)

    ls.update(status: comment)
  end
end
