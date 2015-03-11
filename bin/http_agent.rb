require 'net/http'
require 'pry'

class Agent

  #DEFAULT_URI = 'http://localhost:4567/messages'
  LOCAL_URI = 'http://localhost:9292/messages'
  REMOTE_URI = 'http://dancer.jackdesert.com/messages'
  attr_reader :uri, :from, :subject, :plain, :html
  attr_accessor :body, :phone

  def initialize(plain='plain', html='html', from='from@example.com', subject='hello!')
    @plain = plain
    @html = html
    @subject = subject
    @uri = URI(LOCAL_URI)
  end

  def params
    # Note some of these keys do have title case
    { headers: { From: from, Subject: subject },
      plain: plain }
  end

  def post(override_text=nil)
    res = Net::HTTP.post_form(uri, params)
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
