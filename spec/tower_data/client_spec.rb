require "spec_helper.rb"

RSpec.describe TowerData::Client do
  let(:dummy_email) { 'johndoe@yahoo.com' }
  let(:client) { described_class.new }

  describe '#intelligence' do
    context 'when not given field restrictions' do
      let(:intelligence) { client.intelligence(email: dummy_email) }

      it 'returns all of the fields available' do
        expect(intelligence.keys.size).to be > 1
      end
    end

    context 'when given field restrictions' do
      let(:intelligence) {
        client.intelligence(email: dummy_email, fields: 'marital_status')
      }

      it 'only returns the request fields', :aggregate_failures do
        expect(intelligence.keys).to eq([:marital_status])
      end
    end
  end

  describe '#bulk_intelligence' do
    let(:bulk_intelligence) { client.bulk_intelligence([dummy_email]) }
    let(:expected) {
      client.intelligence(email: dummy_email).tap{ |h| h.delete(:email_validation) }
    }

    it 'returns an array of intelligence values without email_validation' do
      expect(bulk_intelligence).to eq([expected])
    end
  end

  describe '#validation' do
    let(:dummy_email) { 'johndoe@yahoo.com' }

    let(:validation) { client.validation(email: dummy_email) }
    let(:expected) {
      client.intelligence(email: dummy_email)[:email_validation]
    }

    it 'returns only the email_validation value from an intelligence query' do
      expect(validation).to eq(expected)
    end
  end
end
