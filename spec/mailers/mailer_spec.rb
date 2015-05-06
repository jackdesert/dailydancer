require 'spec_helper'

describe Mailer do

  let(:author) { 'Jack <jackdesert@gmail.com>' }
  describe '.confirm_listing' do
    context 'when to is restricted' do
      let(:message) { create(:message, plain: 'May 2') }

      it do
        stub(message).author_multiple_source{ 'Blah Blah Blah <list@sacredcircledance.org>' }
        message.parsed_date.should_not be_nil
        message.author_multiple_source.should include(Message::LIST_EMAIL_ADDRESS)
        email = described_class.confirm_listing(message)
        email.should be_a(Mail::NullMessage)
      end
    end

    context 'when to is not restricted' do
      let(:message) { create(:message, author: author, plain: "March 2") }
      it do
        email = described_class.confirm_listing(message)
        email.should be_a(Mail::Message)
        email.body.should include('http://pdxdailydancer.com')
      end
    end
  end

  describe '.deliver' do
    let(:message) { create(:message, author: author, plain: "March 2") }
    it do
      email = described_class.confirm_listing(message)
      email.should be_a(Mail::Message)
      email.deliver
    end
  end
end
