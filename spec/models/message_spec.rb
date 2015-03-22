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
  let(:valentines_day_at_noon) { Time.new(2015, 2, 14, 12) }

  describe '#parsed_date' do
    context 'when date is in plain' do
      it 'returns date found' do
        # Note received at is on a monday
        message = create(:message, plain: 'December 20', subject: 'this friday', received_at: Time.new(2015, 3, 2))
        message.parsed_date.should == '2015-12-20'
      end
    end

    context 'when there is no date in plain' do
      context 'when there is no relative date in subject' do
        it 'returns nil' do
          # Note received at is on a monday
          message = create(:message, plain: 'Merriweather', subject: 'eminem', received_at: Time.new(2015, 3, 2))
          message.parsed_date.should == nil
        end
      end

      context 'when there is a relative date in subject' do
        it 'returns nil' do
          # Note received at is on a monday
          message = create(:message, plain: 'Merriweather', subject: 'dance this tuesday at 5', received_at: Time.new(2015, 3, 2))
          message.parsed_date.should == '2015-03-03'
        end
      end
    end
  end

  describe '.future' do

    context 'when there are messages' do
      let!(:message_1) { create(:message, plain: 'Feb 13') }
      let!(:message_2) { create(:message, plain: 'Feb 14') }
      let!(:message_3) { create(:message, plain: 'Feb 15') }
      let!(:message_4) { create(:message, plain: 'Feb 14') }
      let!(:message_5) { create(:message, plain: 'Feb 15') }
      it 'returns messages that have present or future parsed_date' do

        pretend_now_is(valentines_day_at_noon) do
          described_class.future.should =~ [message_2, message_3, message_4, message_5]
        end
      end
    end

    context 'when there are no messages' do
      before do
        Message.all.map(&:delete)
      end

      it 'returns an empty Array' do
        pretend_now_is(valentines_day_at_noon) do
          described_class.future.should be_empty
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
        pretend_now_is(valentines_day_at_noon) do
          described_class.by_date(2).should == expected
        end
      end
    end

    context 'when there are no messages' do
      before do
        Message.all.map(&:delete)
      end

      it 'returns a Hash with values that are empty arrays' do
        pretend_now_is(valentines_day_at_noon) do
          described_class.by_date(2).should == { '2015-02-14' => [], '2015-02-15' => [] }
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
end
