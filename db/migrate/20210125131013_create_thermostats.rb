# frozen_string_literal: true

class CreateThermostats < ActiveRecord::Migration[5.2]
  def change
    create_table :thermostats do |t|
      t.string :household_token
      t.string :location

      t.timestamps
    end
  end
end
