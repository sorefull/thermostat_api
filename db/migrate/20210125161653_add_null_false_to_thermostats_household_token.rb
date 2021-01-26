# frozen_string_literal: true

class AddNullFalseToThermostatsHouseholdToken < ActiveRecord::Migration[5.2]
  def up
    change_column :thermostats, :household_token, :string, null: false
    add_index :thermostats, :household_token, unique: true
  end

  def down
    change_column :thermostats, :household_token, :string, null: true
    remove_index :thermostats, name: 'index_thermostats_on_household_token'
  end
end
