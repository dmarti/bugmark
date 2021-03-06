require 'rails_helper'

RSpec.describe ContractCmd::Clone do

  # TEST FOR
  # - rejection of duplicate contracts
  # - invalid parameters

  def gen_obf(opts = {})
    lcl_opts = {volume: 10, price: 0.40, user: user}
    OfferCmd::CreateBuy.new(:offer_bf, lcl_opts.merge(opts)).project
  end

  def valid_params(args = {})
    {
      user: user
    }.merge(args)
  end

  # noinspection RubyArgCount
  let(:offer_bf) { gen_obf.project.offer                                }

  def offer(typ, args = {}) klas.new(typ, valid_params(args)) end

  let(:user)   { FB.create(:user).user                                  }
  let(:klas)   { described_class                                        }
  # noinspection RubyArgCount
  subject      { klas.new(offer_bf, valid_params)                       }

  # describe "Object Existence" do
  #   it { should be_a klas   }
  #   it { should be_valid    }
  # end

  # describe "#project" do
  #   it 'saves the object to the database' do
  #     subject.project
  #     expect(subject).to be_valid
  #   end
  #
  #   it 'gets the right object count' do
  #     hydrate(offer_bf)
  #     expect(Offer.count).to eq(1)
  #     subject.project
  #     expect(Offer.count).to eq(2)
  #   end
  #
  #   it 'updates the clone params' do
  #     hydrate(offer_bf)
  #     expect(Offer.count).to eq(1)
  #     result = klas.new(offer_bf, stm_issue_id: 111).project
  #     expect(Offer.count).to eq(2)
  #     expect(result.offer.stm_issue_id).to eq(111)
  #   end
  # end
  #
  # describe "exceeding user balance and reserves" do
  #   it "does not create an offer" do
  #     hydrate(offer_bf)
  #     expect(Offer.count).to eq(1)
  #     klas.new(offer_bf, volume: 10000).project
  #     expect(Offer.count).to eq(1)
  #   end
  #
  #   it "creates an invalid command" do
  #     hydrate(offer_bf)
  #     expect(Offer.count).to eq(1)
  #     klone = klas.new(offer_bf, volume: 10000)
  #     expect(klone).to_not be_valid
  #   end
  # end
  #
  # describe "cloning a sell offer", USE_VCR do
  #   it "creates an invalid command" do
  #     offer_sf = FB.create(:offer_sf).offer
  #     klone = klas.new(offer_sf, {})
  #     expect(klone).to_not be_valid
  #   end
  # end
end
