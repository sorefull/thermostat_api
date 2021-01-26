# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ReadingsController do
  before do
    allow(controller).to receive(:authenticate_thermostat!) { true }
  end

  describe '#create' do
    before do
      allow(Readings::Create).to receive(:run) { double('Create', success?: true, result: {}) }
    end

    it 'executes create command' do
      expect(Readings::Create).to receive(:run)

      post :create,
           params: { temperature: '30.1', humidity: '30.0', battery_charge: '40.0', household_token: 'test_token' }
    end
  end

  describe '#show' do
    before do
      allow(Readings::Find).to receive(:run) { double('Find', success?: true, result: {}.to_json) }
    end

    it 'executes create command' do
      expect(Readings::Find).to receive(:run)

      get :show, params: { id: '1', household_token: 'test_token' }
    end
  end

  describe '#stats' do
    before do
      allow(Readings::Stats).to receive(:run) { double('Stats', success?: true, result: {}.to_json) }
    end

    it 'executes create command' do
      expect(Readings::Stats).to receive(:run)

      get :stats, params: { household_token: 'test_token' }
    end
  end
end
