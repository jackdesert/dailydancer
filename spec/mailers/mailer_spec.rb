require 'spec_helper'

describe Mailer do

  let(:author) { 'Jack <jackdesert@gmail.com>' }
  let(:message) { create(:message, author: author, plain: 'March 2') }
  describe '.confirm_listing' do
    it do
      email = described_class.confirm_listing(message)
      email.should_not be_nil
    end
  end
end
