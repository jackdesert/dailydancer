require 'spec_helper'

describe Ledger do
  before do
    described_class.redis.flushall
  end

  describe '.record_guest' do
    context 'when passed a string' do
      it 'does not blow up' do
        described_class.record_guest('johnny')
      end
    end

    context 'when passed nil' do
      it 'does not blow up' do
        described_class.record_guest(nil)
      end
    end
  end

  describe '.guest_list' do
    before do
      described_class.record_guest('1')
      described_class.record_guest('2')
      described_class.record_guest('2')
    end

    it 'shows unique guests' do
      described_class.guest_list.should =~ ['1', '2']
    end
  end

  describe '.party_size' do
    before do
      described_class.record_guest('aaa')
      described_class.record_guest('bbb')
      described_class.record_guest('aaa')
    end

    it 'shows the cardinality of the guest list' do
      described_class.party_size.should == 2
    end
  end
end
