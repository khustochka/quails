# encoding: utf-8
require 'open-uri'
require File.expand_path('app/helpers/species_helper', Rails.root)
require 'import/legacy/legacy_init'

module Import
  class SpeciesImport
    extend LegacyInit

    extend SpeciesHelper

    def self.parse_list(url)
      doc = Nokogiri::HTML(open(url), nil, 'utf-8')

      order = family = nil

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').inject([]) do |list, row|
        unless row.content.match(/(?:([A-Z]+FORMES): )?((?:[A-Z]+dae)|(?:Genera Incertae Sedis))\s*$/i).nil?
          order, family = $1, $2
          order = order.nil? ? '' : order.strip.downcase.capitalize
          family = family.strip.downcase.capitalize unless family == 'Genera Incertae Sedis'
        else
          unless family.nil?
            sp_data = row.children
            name_en = sp_data[0].content
            name_sci = sp_data[1].content
            avb_id = sp_data[1].at('a')['href'].match(/^species\.jsp\?avibaseid=([\dA-F]+)$/)[1]
            list.push({
                              :name_sci => name_sci,
                              :name_en => name_en,
                              :order => order,
                              :family => family,
                              :avibase_id => avb_id
                      })
          end
        end
        list
      end
    end

    def self.fill_db(hash)
      require 'app/models/species'
      hash.inject(1) do |index_num, sp|
        Species.create!(
                :name_sci => sp[:name_sci],
                :authority => '',
                :name_en => sp[:name_en],
                :name_ru => '',
                :name_uk => '',
                :order => sp[:order],
                :family => sp[:family],
                :index_num => index_num,
                :avibase_id => sp[:avibase_id]
        )
        index_num + 1
      end
    end

    def self.fetch_details
      require 'app/models/species'
      Species.where(:protonym => nil).each do |sp|
        puts "Fetching details for #{sp.index_num}: #{sp.name_sci}"

        avibase_id = sp[:avibase_id]

        doc_ru = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'RU')), nil, 'utf-8')
        doc_uk = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'UK')), nil, 'utf-8')

        begin
          data_ru = doc_ru.at("//td[@class='AVBHeader']").content.match(/^([^(]+) (\([^)]+\)) (\(?([^()]+)\)?)$/)

          name_ru = data_ru[1].strip

          protonym = doc_ru.at("//p[b[text()='Протоним:']]/i").content.strip

          authority = if sp.name_sci == data_ru[2].strip
                        data_ru[3].strip
                      else
                        proto_parts = protonym.split(' ')
                        sp.name_sci != "#{proto_parts.first} #{proto_parts.last}".downcase.capitalize ?
                                "(#{data_ru[4]})" :
                                "#{data_ru[4]}"
                      end
          name_uk = doc_uk.at("//td[@class='AVBHeader']").content.match(/^(.+) \([A-Za-z ]+\) \(?([^()]+)\)?$/)[1].strip

          name_ru = '' if name_ru.downcase.eql?(sp.name_en.downcase)
          name_uk = '' if name_uk.downcase.eql?(sp.name_en.downcase)

          sp.update_attributes!({
                                        :authority => authority,
                                        :protonym => protonym,
                                        :name_ru => name_ru,
                                        :name_uk => name_uk
                                })
        rescue
          puts "FAILED"
        end
      end
    end

    def self.create_mapping
      require 'import/legacy/models/taxonomy'
      require 'app/models/species'

      init_legacy

      Legacy::Species.where("sp_id <> 'mulspp'").each do |sp|
        unless newsp = (Species.find_by_name_sci(sp[:sp_la]) || Species.find_by_name_en(sp[:sp_en]))
          puts "\n\n\n#{sp[:sp_la]} not found"
          (gen, spnym) = sp[:sp_la].split(' ')
          puts "Possible matches:"
          matches = Species.where("name_sci LIKE '#{gen}%' OR name_sci LIKE '%#{spnym}'")
          (1..matches.size).each do |i|
            puts "#{i}) #{matches[i-1].name_sci}"
          end
          puts "Select option (0 to discard): "
          inpt = $stdin.gets
          newsp = inpt == 0 ? nil : matches[inpt.to_i-1]
        end
        newsp.update_attributes({:code => sp[:sp_id], :name_ru => conv_to_new(sp[:sp_ru]), :name_uk => conv_to_new(sp[:sp_uk])})
      end
    end

    def self.export
      require 'import/legacy/models/taxonomy'
      require 'app/models/species'

      init_legacy

      arr = Species.all
      j = 0
      arr.map { |s| s.order }.uniq.inject(1) do |i, ordo|
        puts ordo.capitalize
        Legacy::Order.create(:ordo_la => ordo, :ordo_en => '', :ordo_ru => '', :ordo_uk => '', :ordo_syn => '', :ordo_id => i)

        arr.select { |s| s.order == ordo }.map { |s2| s2.family }.uniq.each do |fam|
          puts fam
          Legacy::Family.create(:fam_la => fam, :fam_en => '', :fam_ru => '', :fam_uk => '', :fam_syn => '', :fam_id => j += 1, :ordo_id => i)

          arr.select { |s| s.family == fam }.each do |sp|
            puts "*** " + sp.name_sci
            sp_new = Legacy::Species.find_by_sp_id(sp.code) ||
                             Legacy::Species.new(
                                     :sp_la => sp.name_sci,
                                     :sp_ru => conv_to_old(sp.name_ru),
                                     :sp_uk => conv_to_old(sp.name_uk),
                                     :sp_prim => sp.authority
                             )
            sp_new.fam_id = j
            sp_new.sort_num = sp.index_num
            sp_new.sp_en = sp.name_en
            unless sp_new.sp_id
              gen, spn = sp.name_sci.downcase.split(' ')
              sp_new.sp_id = gen[0, 3] + (gen != spn || gen.length < 6 ? spn[0, 3] : spn[-3, 3])
              while consp = Legacy::Species.find_by_sp_id(sp_new.sp_id)
                puts "Conflicting code for #{consp.sp_la} and #{sp_new.sp_la}."
                puts "Enter new for '#{consp.sp_la}':"
                code = $stdin.gets
                Legacy::Species.update_all({:sp_id => code}, "sp_id = '#{consp.sp_id}'")
                puts "Enter new for '#{sp_new.sp_la}':"
                sp_new.sp_id = $stdin.gets
              end
            end
            if sp_new.new_record?
              sp_new.save!
            else
              Legacy::Species.update_all(sp_new.attributes, "sp_id = '#{sp_new.sp_id}'")
            end
          end

        end

        i + 1
      end
    end

    def self.import_codes
      require 'import/legacy/models/taxonomy'
      require 'app/models/species'

      init_legacy

      Species.where("code = '' OR code is NULL").each do |sp|
        sp2 = Legacy::Species.find_by_sp_la(sp.name_sci)

        if sp2.nil?
          puts "\n\n\n#{sp.name_sci} not found"
          (gen, spnym) = sp.name_sci.split(' ')
          puts "Possible matches:"
          matches = Legacy::Species.where("sp_la LIKE '#{gen}%' OR sp_la LIKE '%#{spnym}'")
          (1..matches.size).each do |i|
            puts "#{i}) #{matches[i-1].sp_la}"
          end
          puts "Select option (0 to discard): "
          inpt = $stdin.gets
          sp2 = inpt == 0 ? nil : matches[inpt.to_i-1]
        end

        sp.update_attribute(:code, sp2.sp_id)
      end
    end

  end
end