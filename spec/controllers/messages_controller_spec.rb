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
  context 'POST /messages' do
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

  context 'GET /' do

    context 'when request is from a browser' do
      before do
        # Set the user-agent
        browser.header "User-Agent", "Firefox"
      end

      context 'when not xhr' do
        it 'returns 200' do
          response = browser.get '/'
          response.status.should == 200
        end
      end

      context 'when xhr' do
        it 'returns 200' do
          # Set it to be an XHR request
          # browser.header('X-Requested-With', 'XMLHttpRequest')

          response = browser.get '/?xhr=true'
          response.status.should == 200
        end
      end
    end

    context 'when request is not a browser' do

      # Note user agent is not set in this context

      context 'when not xhr' do
        it 'returns 200' do
          response = browser.get '/'
          response.status.should == 200
        end
      end

      context 'when xhr' do
        it 'returns 200' do
          # Set it to be an XHR request
          # browser.header('X-Requested-With', 'XMLHttpRequest')

          response = browser.get '/?xhr=true'
          response.status.should == 200
        end
      end
    end
  end

end
