# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Thermostats::Authenticate do
  subject { described_class.run(params) }

  let(:params) { { household_token: household_token } }
  let(:household_token) { 'test_token' }

  context 'when household_token is in redis' do
    before do
      allow(Rails.configuration.redis).to receive(:get).with(household_token) { true }
    end

    it 'is successful' do
      expect(subject.result).to be_truthy
    end
  end

  context 'when thermostat can be found in the database' do
    let!(:thermostat) { create(:thermostat, household_token: household_token) }

    before do
      allow(Rails.configuration.redis).to receive(:get).with(household_token) { nil }
    end

    it 'is successful' do
      expect(subject.result).to be_truthy
    end

    it 'searches for thermostat by household_token in the database' do
      expect(Thermostat).to receive(:find_by_household_token).and_return(thermostat)

      subject
    end

    it 'saves household_token in redis' do
      expect(Rails.configuration.redis).to receive(:set).with(household_token, true)

      subject
    end
  end

  context 'when thermostat can not be found at all' do
    before do
      allow(Rails.configuration.redis).to receive(:get).with(household_token) { nil }
    end

    it 'is unsuccessful' do
      expect(subject.result).to be_falsy
    end
  end
end
