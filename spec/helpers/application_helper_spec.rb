require 'spec_helper'

include ApplicationHelper

describe ApplicationHelper do
  describe '#insert_hyperlinks' do
    context 'when there is no hyperlink' do
      it 'returns the original' do
        original = 'hi'
        insert_hyperlinks(original).should == original
      end

      context 'but there is a colon after a word' do
        it 'returns the original' do
        original = 'from: me'
        insert_hyperlinks(original).should == original
        end
      end
    end

    context 'when there is one hyperlink' do
      context 'when there is no period after the hyperlink' do
        it 'inserts an anchor' do
          original = 'Go to http://facebook.com '
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a> "
          insert_hyperlinks(original).should == expected
        end
      end

      context 'when there is a period after the hyperlink' do
        it 'inserts an anchor but leaves the period outside the hyperlink' do
          original = 'Go to http://facebook.com.'
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a>."
        end
      end
    end

    context 'when there are two hyperlinks' do
      context 'when the second hyperlink is a subset of the first' do
        it 'inserts both anchors properly' do
          original = 'Go to http://facebook.com '
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a> "
          insert_hyperlinks(original).should == expected
        end
      end

      context 'when there is a period after the hyperlink' do
        it 'inserts an anchor but leaves the period outside the hyperlink' do
          original = 'http://hi.com/1 and http://hi.com/'
          expected = "<a href='http://hi.com/1' target='_blank'>http://hi.com/1</a> and <a href='http://hi.com/' target='_blank'>http://hi.com/</a>"
          insert_hyperlinks(original).should == expected
        end
      end
    end
  end

  describe '#deduplicate' do
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
        deduplicate([message_1]).should =~ [message_1]
      end
    end

    context 'when there are two messages, and they are duplicates' do
      it 'returns the one with the latest received_at' do
        deduplicate([message_1, message_3]).should =~ [message_1]
      end
    end

    context 'when there are two messages, and they are NOT duplicates' do
      it 'deduplicates' do
        deduplicate([message_1, message_2]).should =~ [message_1, message_2]
      end
    end

    context 'when there are four messages, and some are duplicates' do
      it 'deduplicates' do
        messages = [message_1, message_2, message_3, message_4]
        deduplicate(messages).should =~ [message_1, message_2, message_4]
      end
    end

    context 'when there are nine messages, and there are two patterns of duplicates' do
      it 'deduplicates' do
        messages = [message_1, message_2, message_3, message_4, message_5, message_6, message_7, message_8, message_9]

        deduplicate(messages).should =~ [message_1, message_2, message_4]
      end
    end
  end
end




































