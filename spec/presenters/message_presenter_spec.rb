require 'spec_helper'

describe MessagePresenter do
  describe '.deduplicate' do
    # The assumption here is that those with identical 'plain' will be
    # correctly identified by Message#duplicate_of?(other)
    let(:plain_1)   { 'Dancers' }
    let(:plain_2)   { 'Walkers' }
    let(:plain_3)   { 'Feelers' }
    let(:message_1) { create(:message, plain: plain_1, received_at: Time.new(2014, 12, 1, 9)) }
    let(:message_2) { create(:message, plain: plain_2, received_at: Time.new(2014, 12, 1, 8)) }
    let(:message_3) { create(:message, plain: plain_1, received_at: Time.new(2014, 12, 1, 7)) }
    let(:message_4) { create(:message, plain: plain_3, received_at: Time.new(2014, 12, 1, 6)) }
    let(:message_5) { create(:message, plain: plain_2, received_at: Time.new(2014, 12, 1, 5)) }
    let(:message_6) { create(:message, plain: plain_1, received_at: Time.new(2014, 12, 1, 4)) }
    let(:message_7) { create(:message, plain: plain_3, received_at: Time.new(2014, 12, 1, 3)) }
    let(:message_8) { create(:message, plain: plain_1, received_at: Time.new(2014, 12, 1, 2)) }
    let(:message_9) { create(:message, plain: plain_3, received_at: Time.new(2014, 12, 1, 1)) }

    context 'when there is only one message' do
      it 'returns that message' do
        described_class.send(:deduplicate, [message_1]).should =~ [message_1]
      end
    end

    context 'when there are two messages, and they are duplicates' do
      it 'returns the one with the latest received_at' do
        described_class.send(:deduplicate, [message_1, message_3]).should =~ [message_1]
      end
    end

    context 'when there are two messages, and they are NOT duplicates' do
      it 'described_class.send(:deduplicate)s' do
        described_class.send(:deduplicate, [message_1, message_2]).should =~ [message_1, message_2]
      end
    end

    context 'when there are four messages, and some are duplicates' do
      it 'described_class.send(:deduplicate)s' do
        messages = [message_1, message_2, message_3, message_4]
        described_class.send(:deduplicate, messages).should =~ [message_1, message_2, message_4]
      end
    end

    context 'when there are nine messages, and there are two patterns of duplicates' do
      it 'described_class.send(:deduplicate)s' do
        messages = [message_1, message_2, message_3, message_4, message_5, message_6, message_7, message_8, message_9]

        described_class.send(:deduplicate, messages).should =~ [message_1, message_2, message_4]
      end
    end
  end
end
