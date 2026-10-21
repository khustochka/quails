# frozen_string_literal: true

require "test_helper"

class LogbookSettingTest < ActiveSupport::TestCase
  test "save_all creates world and locus settings" do
    ukraine = loci(:ukraine)
    LogbookSetting.save_all(nil => { life: "1", year: "0" }, ukraine.id => { life: "0", year: "1" })

    world = LogbookSetting.find_by(locus_id: nil)
    assert world.life
    assert_not world.year
    assert LogbookSetting.find_by(locus_id: ukraine.id).year
  end

  test "save_all updates existing settings and removes disabled ones" do
    ukraine = loci(:ukraine)
    LogbookSetting.create!(locus: nil, life: true, year: true)
    LogbookSetting.create!(locus: ukraine, life: true)

    LogbookSetting.save_all(nil => { life: "0", year: "1" }, ukraine.id => { life: "0", year: "0" })

    assert_equal [[nil, false, true]], LogbookSetting.pluck(:locus_id, :life, :year)
  end

  test "only one world setting is allowed" do
    LogbookSetting.create!(locus: nil, life: true)
    assert_not LogbookSetting.new(locus: nil, year: true).valid?
  end

  test "offered_loci includes observed countries with nested subdivisions and lifelist loci" do
    create(:observation, card: create(:card, locus: loci(:brovary)))

    assert_equal [[loci(:ukraine), false], [loci(:kiev_obl), true], [loci(:brovary), true]],
      LogbookSetting.offered_loci
  end

  test "offered_loci includes unobserved loci with enabled settings" do
    LogbookSetting.create!(locus: loci(:usa), life: true)

    assert_includes LogbookSetting.offered_loci, [loci(:usa), false]
  end

  test "offered_loci skips unobserved loci with disabled settings" do
    LogbookSetting.create!(locus: loci(:usa))

    assert_empty LogbookSetting.offered_loci
  end
end
