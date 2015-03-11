# encoding: UTF-8
require 'spec_helper'
require 'rack/test'
require_relative '../../dancer'

class Dancer < Sinatra::Base;end

def valid_params
  # note that the ending line break in a plain message has caused EOF errors,
  # therefore it's being stripped out before sending
  { plain: "I’m fäncy inpüts\n",
    headers: { Subject: "söme subject",
               From: 'Julia Chḯld <child@child.net>'}
  }
end

def invalid_params
  { who: 'there' }
end

describe 'the controller' do
  #let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application)) }
  let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Dancer)) }
  context 'with valid params' do
    it 'returns 201' do
      response = browser.post '/messages', valid_params
      response.status.should == 201
    end

    it 'creates a Message' do
      expect {
        response = browser.post '/messages', valid_params
      }.to change { Message.count }.by(1)
    end
  end

  context 'with invalid params' do
    it 'returns 400' do
      response = browser.post '/messages', invalid_params
      response.status.should == 400
    end
  end
end
