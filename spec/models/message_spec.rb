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

  describe '.by_date', focus: true do
    let(:valentines_day) { Date.new(2015, 2, 14) }

    context 'when there are messages' do
      let!(:message_1) { create(:message, received_at: '2015-02-13') }
      let!(:message_2) { create(:message, received_at: '2015-02-15') }
      let!(:message_3) { create(:message, received_at: '2015-02-14') }
      let!(:message_4) { create(:message, received_at: '2015-02-15') }
      let!(:message_5) { create(:message, received_at: '2015-02-14') }
      it 'returns them in order' do
        expected  = { '2015-02-14' => [message_3, message_5],
                      '2015-02-15' => [message_2, message_4] }
        described_class.by_date(2).should == expected
      end
    end

    context 'when there are no messages' do
      before do
        Message.all.map(&:delete)
      end

      it 'returns a Hash with values that are empty arrays' do
        pretend_now_is(valentines_day)
        described_class.by_date(2).should == { '2015-02-14' => [], '2015-02-15' => [] }
      end
    end
  end

  describe '#parse_date' do
    hash =  { 'Sunday Mar 15, 2015' => '2015-03-15',
              'Mar. 17'             => '2015-13-17',
              'OCTOBER 3'           => '2015-10-03' }

    hash.each do |text, expected_date|
      context "when text is #{text}" do
        it "returns #{expected_date}" do
          message = described_class.new(plain: text)
          message.parse_date.should == expected_date
        end
      end
    end
  end
end
