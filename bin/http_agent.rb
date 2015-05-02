require 'net/http'
require 'pry'
require 'json'

class Agent

  #DEFAULT_URI = 'http://localhost:4567/messages'
  LOCAL_URI = 'http://localhost:9292/messages'
  REMOTE_URI = 'http://pdxdailydancer-staging.com/messages'
  attr_reader :uri
  attr_accessor :body, :phone, :from, :subject, :plain, :html

  def initialize(plain='plain', html='html', from='from@example.com', subject='hello!')
    @plain   = plain
    @html    = html
    @subject = subject
    @from    = from
    @uri     = URI(LOCAL_URI)
  end

  def params
    # Note some of these keys do have title case
    { headers:  {
                  From: from,
                  Subject: subject
                },
      plain: plain,
      html: html
    }
  end

  def post
    req = Net::HTTP::Post.new(uri)
    req.body = params.to_json
    req.set_content_type('application/json')

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
    res.body
  end

  def uri=(input)
    @uri = URI(input)
  end

  def local
    @uri = URI(LOCAL_URI)
  end

  def remote
    @uri = URI(REMOTE_URI)
  end


end

a = Agent.new
binding.pry
a = 'hi'
