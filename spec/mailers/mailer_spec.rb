require 'spec_helper'

describe Mailer do

  let(:author) { 'Jack <jackdesert@gmail.com>' }
  let(:message) { create(:message, author: author, plain: "From: list@sacredcircledance.org\n\nMarch 2") }
  describe '.confirm_listing' do
    context 'when to is restricted' do
      it do
        # the only way to force 'to' to be restricted is to set it as both the author and in the first line of plain
        message.author = 'Blah Blah Blah <list@sacredcircledance.org>'
        message.parsed_date.should_not be_nil
        message.author_multiple_source.should include(Message::LIST_EMAIL_ADDRESS)
        email = described_class.confirm_listing(message)
        email.should be_a(Mail::NullMessage)
      end
    end

    context 'when to is not restricted' do
      it do
        email = described_class.confirm_listing(message)
        email.should be_a(Mail::Message)
        email.body.should include('http://pdxdailydancer.com')
      end
    end
  end

  describe '.deliver' do
    it do
      email = described_class.confirm_listing(message)
      email.should_not be_nil
      email.deliver
    end
  end
end
