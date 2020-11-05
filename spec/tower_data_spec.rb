require "spec_helper.rb"

RSpec.describe TowerData do
  it "has a version number" do
    expect(TowerData::VERSION).not_to be nil
  end

  describe '.client' do
    let(:client_double) { instance_double(TowerData::Client) }
    before do
      stub_const('TowerData::API_KEY', 'XXX')
    end

    it 'instantiates a client using the API_KEY' do
      expect(TowerData::Client).to receive(:new).once.and_return(client_double)

      expect(TowerData.client).to eq(client_double)
    end
  end
end
