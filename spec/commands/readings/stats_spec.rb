require 'rails_helper'

RSpec.describe Readings::Stats do
  subject { described_class.run(params) }


  let(:params) { { household_token: household_token } }
  let(:household_token) { 'test-token' }

  before do
    allow($redis).to receive(:get).with("#{household_token}.count") { temperature_records.count }

    allow($redis).to receive(:get).with("#{household_token}.temperature_sum") { temperature_records.sum.to_s }
    allow($redis).to receive(:get).with("#{household_token}.temperature_min") { temperature_records.min.to_s }
    allow($redis).to receive(:get).with("#{household_token}.temperature_max") { temperature_records.max.to_s }

    allow($redis).to receive(:get).with("#{household_token}.humidity_sum") { humidity_records.sum.to_s }
    allow($redis).to receive(:get).with("#{household_token}.humidity_min") { humidity_records.min.to_s }
    allow($redis).to receive(:get).with("#{household_token}.humidity_max") { humidity_records.max.to_s }

    allow($redis).to receive(:get).with("#{household_token}.battery_charge_sum") { battery_charge_records.sum.to_s }
    allow($redis).to receive(:get).with("#{household_token}.battery_charge_min") { battery_charge_records.min.to_s }
    allow($redis).to receive(:get).with("#{household_token}.battery_charge_max") { battery_charge_records.max.to_s }
  end

  let(:temperature_records) { [25.4, 27.0, 24.4] }
  let(:humidity_records) { [40.3, 30.2, 35.2] }
  let(:battery_charge_records) { [50.5, 49.9, 48.9] }

  it 'uses sums and count to calculate avg temperature, humidity and battery_charge' do
    expect(subject.result[:avg_temperature]).to eq(25.599999999999998)
    expect(subject.result[:avg_humidity]).to eq(35.233333333333334)
    expect(subject.result[:avg_battery_charge]).to eq(49.76666666666667)
  end
end
