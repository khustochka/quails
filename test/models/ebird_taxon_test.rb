# frozen_string_literal: true

require "test_helper"

class EbirdTaxonTest < ActiveSupport::TestCase

  test "if already promoted should return taxon" do
    etx = ebird_taxa(:pasdom)
    tx = etx.taxon

    assert_difference "Taxon.count", 0 do
      @result = etx.promote
    end

    assert_equal tx, @result
  end

  test "should elevate detached taxon" do
    etx = ebird_taxa(:some_spuh)

    assert_difference "Taxon.count", 1 do
      @result = etx.promote
    end

    etx.reload
    assert_equal etx.taxon, @result
  end

  test "if taxon is a species should also create a species" do
    etx = ebird_taxa(:some_species)


    assert_difference "Species.count", 1 do
      assert_difference "Taxon.count", 1 do
        @result = etx.promote
      end
    end

    etx.reload
    assert_equal etx.taxon, @result
    assert_predicate etx.taxon.species, :present?
    assert_predicate etx.taxon.species.taxa, :present?
  end

  test "promote taxon with parent already promoted" do
    etx = ebird_taxa(:barn_swallow_subspecies)

    assert_difference "Taxon.count", 1 do
      @result = etx.promote
    end

    etx.reload
    assert_equal etx.taxon, @result
    assert_equal etx.parent.taxon, @result.parent
    assert_equal etx.parent.taxon.species, @result.species
  end

  test "promote taxon with parent not yet promoted should promote parent" do
    etx = ebird_taxa(:some_tinamu_subspecies)

    assert_difference "Species.count", 1 do
      assert_difference "Taxon.count", 2 do
        @result = etx.promote
      end
    end

    etx.reload
    assert_equal etx.taxon, @result
    assert_equal etx.parent.taxon, @result.parent
    assert_predicate etx.parent.taxon.species, :present?
    assert_equal etx.parent.taxon.species, @result.species
  end

  test "index num is set up properly" do
    # normalize indexing
    EbirdTaxon.order(:index_num).each_with_index { |tx, i| tx.update_column(:index_num, i+1) }
    Taxon.order(:index_num).each_with_index { |tx, i| tx.update_column(:index_num, i+1) }
    Species.order(:index_num).each_with_index { |sp, i| sp.update_column(:index_num, i+1) }
    first_taxon = Taxon.order(:index_num).first
    first_sp = Species.order(:index_num).first
    etx = ebird_taxa(:some_tinamu_subspecies)
    @result = etx.promote
    assert_equal 1, etx.parent.taxon.index_num
    assert_equal 1, etx.taxon.species.index_num
    assert_equal 2, etx.taxon.index_num
    first_taxon.reload
    first_sp.reload
    assert_equal 3, first_taxon.index_num
    assert_equal 2, first_sp.index_num
  end

end
