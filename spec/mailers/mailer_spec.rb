require 'spec_helper'

describe Mailer do

  let(:author) { 'Jack <jackdesert@gmail.com>' }
  let(:message) { create(:message, author: author) }
  describe '.confirm_listing' do
    it do
      described_class.confirm_listing(message)
    end
  end
end
