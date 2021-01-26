require 'rails_helper'

RSpec.describe Readings::Create do
  subject { described_class.run(params) }

  let(:params) do
    {
      temperature: temperature,
      humidity: humidity,
      battery_charge: battery_charge,
      household_token: household_token
    }
  end

  let(:expected_reading) do
    {
      temperature: temperature,
      humidity: humidity,
      battery_charge: battery_charge
    }
  end

  let(:temperature) { 27.4 }
  let(:humidity) { 40.4 }
  let(:battery_charge) { 60.0 }
  let(:household_token) { 'test_token' }

  before do
    allow($redis).to receive(:set)
    allow($redis).to receive(:get)
    allow($redis).to receive(:incr)
    allow($redis).to receive(:incrbyfloat)

    # default value that is not affecting logic
    allow($redis).to receive(:get).with("#{household_token}.count") { 2 }

    allow(SaveReadingJob).to receive(:perform_later)
  end

  it 'saves reading to redis' do
    expect($redis).to receive(:set).with(household_token, expected_reading.to_json)

    subject
  end

  it 'saves some totals' do
    expect($redis).to receive(:incrbyfloat).with("#{household_token}.temperature_sum", temperature)
    expect($redis).to receive(:incrbyfloat).with("#{household_token}.humidity_sum", humidity)
    expect($redis).to receive(:incrbyfloat).with("#{household_token}.battery_charge_sum", battery_charge)

    subject
  end

  context "when there's no readings" do
    it "set's all min/max(s)" do
      expect($redis).to receive(:set).with("#{household_token}.temperature_min", temperature)
      expect($redis).to receive(:set).with("#{household_token}.temperature_max", temperature)
      expect($redis).to receive(:set).with("#{household_token}.humidity_min", humidity)
      expect($redis).to receive(:set).with("#{household_token}.humidity_max", humidity)
      expect($redis).to receive(:set).with("#{household_token}.battery_charge_min", battery_charge)
      expect($redis).to receive(:set).with("#{household_token}.battery_charge_max", battery_charge)

      subject
    end
  end

  context "when there's a reading" do
    let(:reading) { create(:reading, temperature: temperature - 5, humidity: humidity + 5, battery_charge: battery_charge ) }

    before do
      allow($redis).to receive(:get).with("#{household_token}.temperature_min") { reading.temperature }
      allow($redis).to receive(:get).with("#{household_token}.temperature_max") { reading.temperature }
      allow($redis).to receive(:get).with("#{household_token}.humidity_min") { reading.humidity }
      allow($redis).to receive(:get).with("#{household_token}.humidity_max") { reading.humidity }
      allow($redis).to receive(:get).with("#{household_token}.battery_charge_min") { reading.battery_charge }
      allow($redis).to receive(:get).with("#{household_token}.battery_charge_max") { reading.battery_charge }
    end

    it "set's min/max(s) only when needed" do
      expect($redis).to receive(:set).with("#{household_token}.temperature_max", temperature)
      expect($redis).to receive(:set).with("#{household_token}.humidity_min", humidity)

      expect($redis).not_to receive(:set).with("#{household_token}.temperature_min", temperature)
      expect($redis).not_to receive(:set).with("#{household_token}.humidity_max", humidity)
      expect($redis).not_to receive(:set).with("#{household_token}.battery_charge_min", battery_charge)
      expect($redis).not_to receive(:set).with("#{household_token}.battery_charge_max", battery_charge)

      subject
    end
  end

  it 'increments sequence_number' do
    expect($redis).to receive(:incr).with("#{household_token}.count")

    subject
  end

  it 'enqueues SaveReadingJob' do
    expect(SaveReadingJob).to receive(:perform_later).with(
      params.merge(number: 2)
    )

    subject
  end
end
