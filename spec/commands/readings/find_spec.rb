require 'rails_helper'

RSpec.describe Readings::Find do
  subject { described_class.run(params) }

  let(:params) do
    {
      number: number,
      household_token: thermostat.household_token
    }
  end

  before do
    allow($redis).to receive(:get).with("#{thermostat.household_token}.count") { "2" }
    allow($redis).to receive(:get).with(thermostat.household_token) { json_reading }
  end

  let(:json_reading) { reading_2.attributes.slice('temperature', 'humidity', 'battery_charge').to_json }

  let(:thermostat) { create(:thermostat) }
  let!(:reading_1) { create(:reading, thermostat: thermostat, number: 1) }
  let!(:reading_2) { create(:reading, thermostat: thermostat, number: 2) }

  context 'when the requested reading is stored in redis' do
    let(:number) { 2 }

    it 'uses redis to fetch it' do
      expect($redis).to receive(:get).with(thermostat.household_token)

      subject
    end
  end

  context 'when the requested reading is not the last one' do
    let(:number) { 1 }

    it 'uses activerecord to fetch it' do
      expect(Thermostat).to receive_message_chain(:find_by_household_token, :readings, :find_by_number)

      subject
    end
  end
end
