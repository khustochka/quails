# frozen_string_literal: true

class NormalizeBlankStringsToNil < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE cards SET ebird_id = NULL WHERE ebird_id = ''"
    execute "UPDATE cards SET start_time = NULL WHERE start_time = ''"
    execute "UPDATE media SET external_id = NULL WHERE external_id = ''"
    execute "UPDATE species SET code = NULL WHERE code = ''"
    execute "UPDATE species SET legacy_code = NULL WHERE legacy_code = ''"
  end

  def down
    # no-op
  end
end
