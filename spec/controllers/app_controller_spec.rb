# encoding: UTF-8

require 'spec_helper'
require 'rack/test'
require_relative '../../daily_lager'

def sample_params_from_twilio
  {
    "AccountSid"=>"test_sid",
    "MessageSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "Body"=>"Hi6",
    "ToZip"=>"83647",
    "ToCity"=>"MT HOME",
    "FromState"=>"ID",
    "ToState"=>"ID",
    "SmsSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "To"=>"+12086960499",
    "ToCountry"=>"US",
    "FromCountry"=>"US",
    "SmsMessageSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "ApiVersion"=>"2010-04-01",
    "FromCity"=>"GLENNS FERRY",
    "SmsStatus"=>"received",
    "NumMedia"=>"0",
    "From"=>"+12083666059",
    "FromZip"=>"83633"
  }
end

def sample_params_from_browser
  {
    "Body"=>"Hi6",
    "secret"=>"my_secret"
  }
end

def rogue_params
  {
    # Note that we are not guarding against the case where Twilio
    # does not provide a 'From' field
    "From" =>"+12223334444",
    'blither' => 'blather'
  }
end

def browser
  browser_with_methods = Rack::Test::Session.new(Rack::MockSession.new(DailyLager))

  def browser_with_methods.json_post(uri, params)
    json_content_type_hash = { 'CONTENT_TYPE' => 'application/json' }
    self.post(uri, params.to_json, json_content_type_hash)
  end

  browser_with_methods
end



describe '/' do
  context 'when no secret given' do
    subject { browser.get '/' }
    it 'returns 404' do
      subject.status.should == 404
    end
  end

  context 'when secret does not match a Human' do
    subject { browser.get '/', secret: 'blither-blather' }
    it 'returns 404' do
      subject.status.should == 404
    end
  end

  context 'when secret matches a Human' do
    let(:human) { create(:human) }
    subject { browser.get '/', secret: human.secret }
    it 'returns 200' do
      subject.status.should == 200
    end
  end
end

describe 'POST /messages' do
  context 'using sample params from browser' do
    subject { browser.json_post '/messages', sample_params_from_browser }
    it 'returns 200' do
      subject.status.should == 200
    end

    context 'when user exists' do
      let!(:human) { create(:human, secret: 'my_secret') }

      it 'makes a call to Verb#responder' do
        mock.proxy.any_instance_of(NonsenseVerb).response.returns('something')
        subject
      end
    end

    context 'when the user does not exist' do
      before do
        DB[:humans].delete
      end

      it 'returns an error' do
        subject.body.should == "Oops. We've encountered an error: 'please provide the correct secret'"
      end
    end
  end

  context 'using sample params from twilio' do
    subject { browser.json_post '/messages', sample_params_from_twilio }
    it 'returns 200' do
      subject.status.should == 200
    end

    it 'makes a call to Verb#responder' do
      mock.proxy.any_instance_of(NonsenseVerb).response.returns('something')
      subject
    end

    context 'when the message is 160 characters' do
      it 'returns the whole message' do
        dummy_output = 'y' * 160
        mock.proxy.any_instance_of(NonsenseVerb).response.returns(dummy_output)
        subject.body.should == dummy_output
      end
    end

    context 'when the message is more than 160 characters' do
      it "returns 154 characters and the word 'snip'" do
        dummy_output = 'h' * 161
        mock.proxy.any_instance_of(NonsenseVerb).response.returns(dummy_output)
        subject.body.should == 'h' * 154 + '[snip]'
      end
    end

    context 'when the user does not exist' do
      before do
        DB[:humans].delete
      end

      it 'creates the user' do
        expect{
          subject
        }.to change{ Human.count }.by(1)
      end
    end

    context 'when the user exists' do
      it 'looks up the user and uses it' do
      end
    end
  end

  context 'using rogue params' do
    subject { browser.json_post '/messages', rogue_params }

    it 'returns 200' do
      subject.status.should == 200
    end

    it 'returns an error' do
      subject.body.should == "Oops. We've encountered an error: 'invalid secret'"
    end
  end
end

