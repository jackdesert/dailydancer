require 'spec_helper'

describe Message do


  #before do
  #  mock(Date).today.never
  #end

  #let(:today)           { Util.current_date_in_california }
  #let(:yesterday)       { today - 1 }
  #let(:two_days_ago)    { today - 2 }
  #let(:three_days_ago)  { today - 3 }
  #let(:four_days_ago)   { today - 4 }

  #context 'validations' do
  #  context 'secret' do
  #    context 'before_create' do
  #      context 'when secret already exists' do
  #        it 'does nothing' do
  #          secret = 'mine'
  #          human = Human.create(phone_number: '+12223334446', secret: secret)
  #          human.secret.should == secret
  #          human.id.should_not be_nil
  #        end
  #      end

  #      context 'when secret is blank' do
  #        it 'creates a secret' do
  #          human = Human.create(phone_number: '+12223334447')
  #          human.secret.length.should == 8
  #        end
  #      end
  #    end

  #    it 'is unique' do
  #      secret = 'abc'
  #      fred = Human.create(phone_number: '+12223334444', secret: secret)
  #      debi = Human.new(phone_number: '+12223334445', secret: secret)
  #      debi.should have_error_on(:secret)
  #      debi.secret = 'something_else'
  #      debi.should_not have_error_on(:secret)
  #    end
  #  end

  #  context 'phone number' do
  #    context 'format' do
  #      context 'valid phone numbers' do
  #        valid_numbers = ['+11112223333', '+19998887777']
  #        valid_numbers.each do |number|
  #          subject { described_class.new(phone_number: number) }
  #          context "when the phone number is #{number}" do
  #            it { should_not have_error_on(:phone_number) }
  #          end
  #        end
  #      end

  #      context 'invalid phone numbers' do
  #        invalid_numbers = ['1', '12', '+123.456.4444', '&1112223333', '11112223333']
  #        invalid_numbers.each do |number|
  #          subject { described_class.new(phone_number: number) }
  #          context "when the phone number is #{number}" do
  #            it { should have_error_on(:phone_number) }
  #          end
  #        end
  #      end
  #    end
  #    context 'uniqueness' do
  #      let(:number) { '+12222222222' }
  #      let!(:first_human) { Human.create(phone_number: number) }
  #      let(:second_human) { Human.new(phone_number: number) }
  #      it 'marks the second human as invalid' do
  #        first_human.should be_valid
  #        second_human.should have_error_on(:phone_number)
  #      end
  #    end
  #  end
  #end
  #
  #
  #

  # Note this is at noon so that regardless of which time zone you are actually in the
  # date still comes out right
  let(:valentines_day_2015_at_noon) { Time.new(2015, 2, 14, 12) }

  describe '#not_an_event?' do
    { 'apartment for rent' => true,
      'looking for studio to rent' => true,
      'anything with the word rent and spaces around it' => true,
      'Brent Barker' => false,
      '1 bedroom' => true,
      '2 bedroom' => true,
      '3 bedroom' => true,
      '4 bedroom' => true,
      'one bedroom' => true,
      'two bedroom' => true,
      'three bedroom' => true,
      'four bedroom' => true,
      'house sit for me' => true,
      'pet sit for me' => true,
      'dog sitters are cool' => true,
      'cat sitters are cool' => true,
      'sublet my office' => true,
      'month to month available' => true,
      'go to kickstarter.com' => true,
      'looking for therapy space' => true,
      'AstrologyNow Forecast' => true,
      'dogs are fun' => false}.each do |text, response|
      context "When plain is #{text}" do
        it "returns #{response}" do
          # Note subject is set to empty string because #not_an_event? adds subject and plain
          described_class.new(subject: '', plain: text).not_an_event?.should == response
        end
      end

      context "When subject is #{text}" do
        it "returns #{response}" do
          # Note plain is set to empty string because #not_an_event? adds subject and plain
          described_class.new(subject: text, plain: '').not_an_event?.should == response
        end
      end
    end
  end

  describe '#parse' do
    let(:message) { described_class.new(author: 'author', subject: 'subject', plain: 'plain' ) }
    let(:date) { '2000-01-02' }
    it 'calls parsed_date' do
      mock(message).parsed_date
      message.parse
    end

    it 'sets event_date' do
      mock(message).parsed_date.returns{ date }
      message.parse
      message.event_date.should == date
    end
  end

  describe '#parsed_date' do
    context 'when there is no relative date in subject' do
      it 'returns nil' do
        # Note received at is on a monday
        message = create(:message, plain: 'Merriweather', subject: 'eminem', received_at: Time.new(2015, 3, 2))
        message.parsed_date.should == nil
      end
      context 'but date is in plain' do
        it 'returns date found' do
          # Note received at is on a monday
          message = create(:message, plain: 'February 15', subject: 'fantastic evening', received_at: Time.new(2015, 2, 2))

          message.parsed_date.should == '2015-02-15'

          pretend_now_is(Date.new(1900, 1, 1)) do
            # The test inside this "pretend_now_is" block ensures that
            # message.received_at is passed in the options hash to Chronic.
            # Otherwise this spec will fail because it will get the year wrong
            message.parsed_date.should == '2015-02-15'
          end

        end

        context 'but plain includes "room for rent" which triggers not_an_event?' do
          it 'returns nil' do
            message = create(:message, plain: 'December 20 room for rent', subject: 'this friday', received_at: Time.new(2015, 3, 2))
            message.parsed_date.should be_nil
          end
        end
      end
    end

    context 'when there is a relative date in subject' do
      it 'returns that date' do
        # Note received at is on a monday
        message = create(:message, subject: 'dance this tuesday at 5', received_at: Time.new(2015, 3, 2))
        message.parsed_date.should == '2015-03-03'
      end

      context 'but plain includes "room for rent" which triggers not_an_event?' do
        it 'returns nil' do
          message = create(:message, subject: 'This Friday', plain: 'sublet', received_at: Time.new(2015, 3, 2))
          message.parsed_date.should be_nil
        end
      end
    end
  end

  describe '.by_date' do

    context 'when there are messages' do
      let!(:message_1) { create(:message, plain: 'Feb 13') }
      let!(:message_2) { create(:message, plain: 'Feb 14') }
      let!(:message_3) { create(:message, plain: 'Feb 15') }
      let!(:message_4) { create(:message, plain: 'Feb 14') }
      let!(:message_5) { create(:message, plain: 'Feb 15') }
      it 'returns them in order' do
        expected  = { '2015-02-14' => [message_2, message_4],
                      '2015-02-15' => [message_3, message_5] }
        pretend_now_is(valentines_day_2015_at_noon) do
          described_class.by_date(2, 0).should == expected
        end
      end
    end

    context 'when there are no messages' do
      before do
        Message.all.map(&:delete)
      end

      it 'returns a Hash with values that are empty arrays' do
        pretend_now_is(valentines_day_2015_at_noon) do
          described_class.by_date(2, 0).should == { '2015-02-14' => [], '2015-02-15' => [] }
        end
      end
    end
  end

  describe '.by_date_empty' do
    context 'when num_days is 2 and offset is 1' do
      it 'returns empty arrays for tomorrow and the next day' do
        pretend_now_is(valentines_day_2015_at_noon) do
          described_class.by_date_empty(2, 1).should == { '2015-02-15' => [], '2015-02-16' => [] }
        end
      end
    end
  end

  describe '#duplicate_of?' do
    context 'when content is exactly the same' do
      let(:plain) { "June 14 there is.something playing.at the fair.that might interest.you." }
      let(:message_1) { create(:message, plain: plain) }
      let(:message_2) { create(:message, plain: plain) }

      it do
        message_1.duplicate_of?(message_2).should == true
      end
    end

    context 'when four of five lines are the same' do
      let(:plain_1) { "June 14 there is.something playing.at the fair.that might interest.you." }
      let(:plain_2) { "June 14 there is.THIS IS DIFFERENT.at the fair.that might interest.you." }
      let(:subject_1) { 'one two three four Amy' }
      let(:subject_2) { 'one two three four Fred' }
      let(:message_1) { create(:message, plain: plain_1, subject: subject_1) }
      let(:message_2) { create(:message, plain: plain_2, subject: subject_2) }

      it do
        message_1.duplicate_of?(message_2).should == true
      end
    end

    context 'when two of five lines are the same' do
      let(:plain_1) { "June 14 there is.something playing.at the fair.that might interest.you." }
      let(:plain_2) { "June 14 there is.THIS IS DIFFERENT.THIS TOO.that might interest.you." }
      let(:subject_1) { 'one two Amy Rose Charles' }
      let(:subject_2) { 'one two Fred Randy Dan' }
      let(:message_1) { create(:message, plain: plain_1, subject: subject_1) }
      let(:message_2) { create(:message, plain: plain_2, subject: subject_2) }

      it do
        message_1.duplicate_of?(message_2).should == false
      end
    end
  end

  describe '#hidden' do
    it 'defaults to false' do
      create(:message).hidden.should == false
    end
  end

  describe '.num_hidden' do
    before do
      described_class.map(&:delete)
    end

    let!(:message) { create(:message) }

    context 'when none are hidden' do
      it 'returns 0' do
        described_class.num_hidden.should == 0
      end
    end

    context 'when one is hidden' do
      it 'returns 0' do
        message.hide('reason')
        described_class.num_hidden.should == 1
      end
    end
  end

  describe '#author_multiple_source' do
    context 'when author includes LIST_ADDRESS' do
      context 'when first line of plain shows author email' do
        let(:plain) { "From: James@brown.com\n\nDiscover Yourself!" }
        let(:message) { create(:message, plain: plain, author: 'list@sacredcircledance.org (=?UTF-8?Q?Amie_Charles?=)') }
        it 'uses the author from plain' do
          message.author_multiple_source.should == 'Amie Charles <James@brown.com>'
        end
      end

      context 'when first line of plain does not show author' do
        let(:plain) { "Discover Yourself!\n\nToday!" }
        let(:message) { create(:message, plain: plain, author: 'Blah Blah Blah <list@sacredcircledance.org>') }
        it 'returns unknown' do
          message.author_multiple_source.should == 'unknown'
        end
      end
    end

    context 'when author is nobody@simplelist.com' do
      context 'when the author is in the first line of plain' do
        let(:plain) { "This email was sent from yahoo.com which does not allow forwarding of emails via email lists. Therefore the sender's email address (touch@yahoo.com) has been replaced with a dummy one. The original message follows:\n\nFire" }
        let(:message) { create(:message, plain: plain, author: "\"Carolyn Sleuth (via sacredcircledance list)\" <nobody@simplelists.com>") }
        it 'uses the author from plain' do
          message.author_multiple_source.should == 'Carolyn Sleuth <touch@yahoo.com>'
        end
      end

      context 'when the author is not the first line of plain' do
        let(:message) { create(:message, plain: 'Fire', author: "\"Carolyn Sleuth (via sacredcircledance list)\" <nobody@simplelists.com>") }
        it 'returns unknown' do
          message.author_multiple_source.should == 'unknown'
        end
      end
    end

    context 'when author does not include LIST_ADDRESS' do
      let(:plain) { "From: Laureli@thrive-wise.com\n\nDiscover Yourself!" }
      let(:message) { create(:message, plain: plain, author: 'A Real Author <real@author.com>') }
      it 'uses the author from plain' do
        message.author_multiple_source.should == 'A Real Author <real@author.com>'
      end
    end
  end

  describe '#author_first_name' do
    let(:message) { described_class.new }
    hash =  { 'Jo Ma <jo@ma.com>' => 'Jo',
              'JoMa <jo@ma.com>'  => 'JoMa',
              '<jo@ma.com>'       => 'jo@ma.com',
              'jo@ma.com'         => 'jo@ma.com' }

    hash.each do |full_email, first_name|
      context "when author is #{full_email}" do
        it "returns #{first_name}" do
          stub(message).author_multiple_source.returns(full_email)
          message.author_first_name.should == first_name
        end
      end
    end
  end

  describe 'before_create callback' do
    let(:message) { described_class.new(author: 'author', subject: 'subject', plain: 'plain' ) }
    let(:date) { '2000-01-02' }
    it 'sets event_date to parsed_date' do
      stub(message).parsed_date.returns(date)
      message.save
      message.event_date.should == date
    end
  end
end
