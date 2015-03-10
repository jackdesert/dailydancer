require 'spec_helper'

describe Message do
  before do
    mock(Date).today.never
  end

  let(:today)           { Util.current_date_in_california }
  let(:yesterday)       { today - 1 }
  let(:two_days_ago)    { today - 2 }
  let(:three_days_ago)  { today - 3 }
  let(:four_days_ago)   { today - 4 }

  context 'validations' do
    context 'secret' do
      context 'before_create' do
        context 'when secret already exists' do
          it 'does nothing' do
            secret = 'mine'
            human = Human.create(phone_number: '+12223334446', secret: secret)
            human.secret.should == secret
            human.id.should_not be_nil
          end
        end

        context 'when secret is blank' do
          it 'creates a secret' do
            human = Human.create(phone_number: '+12223334447')
            human.secret.length.should == 8
          end
        end
      end

      it 'is unique' do
        secret = 'abc'
        fred = Human.create(phone_number: '+12223334444', secret: secret)
        debi = Human.new(phone_number: '+12223334445', secret: secret)
        debi.should have_error_on(:secret)
        debi.secret = 'something_else'
        debi.should_not have_error_on(:secret)
      end
    end

    context 'phone number' do
      context 'format' do
        context 'valid phone numbers' do
          valid_numbers = ['+11112223333', '+19998887777']
          valid_numbers.each do |number|
            subject { described_class.new(phone_number: number) }
            context "when the phone number is #{number}" do
              it { should_not have_error_on(:phone_number) }
            end
          end
        end

        context 'invalid phone numbers' do
          invalid_numbers = ['1', '12', '+123.456.4444', '&1112223333', '11112223333']
          invalid_numbers.each do |number|
            subject { described_class.new(phone_number: number) }
            context "when the phone number is #{number}" do
              it { should have_error_on(:phone_number) }
            end
          end
        end
      end
      context 'uniqueness' do
        let(:number) { '+12222222222' }
        let!(:first_human) { Human.create(phone_number: number) }
        let(:second_human) { Human.new(phone_number: number) }
        it 'marks the second human as invalid' do
          first_human.should be_valid
          second_human.should have_error_on(:phone_number)
        end
      end
    end
  end

  describe '#things' do
    it 'is an array' do
      described_class.new.things.should be_an Array
    end
  end

  describe '#thing_names' do
    let(:human) { create(:human) }
    subject { human.thing_names }
    context 'when human has no things' do
      it { should == [] }
    end

    context 'when human has things' do
      before do
        human.add_thing(name: 'voila')
        human.add_thing(name: 'abcgum')
      end
      it { should == ['voila', 'abcgum'] }
    end
  end


  describe '#date_of_most_recent_occurrence' do
    let(:human) { create(:human)  }
    context 'when there are no occurrences' do
      subject { human.date_of_most_recent_occurrence }
      it { should be_nil }
    end

    context 'when there are occurrences' do

      let(:run_occurrences) { [ Occurrence.create(date: four_days_ago), Occurrence.new(date:three_days_ago) ] }
      let(:run_thing) { Thing.create(name: 'run', default_value: 13) }
      let(:walk_thing) { Thing.create(name: 'walk', default_value: 13) }

      before do
        run_thing.add_occurrence(date:three_days_ago, value: 0)
        run_thing.add_occurrence(date:four_days_ago, value: 0)
        human.add_thing(run_thing)
        human.add_thing(walk_thing)
      end

      it 'returns a Date' do
        human.date_of_most_recent_occurrence.should be_an Date
      end

      it 'returns the most recent' do
        human.date_of_most_recent_occurrence.should == three_days_ago
        walk_thing.add_occurrence(date:two_days_ago, value: 0)
        human.date_of_most_recent_occurrence.should == two_days_ago
      end
    end
  end

  describe '#backfill' do
    let(:today_occurrence) { Occurrence.create(value: 10) }
    let(:yesterday_occurrence) { Occurrence.create(value: 11, date: yesterday) }
    let(:two_days_ago_occurrence) { Occurrence.create(value: 12, date: two_days_ago) }
    let(:three_days_ago_occurrence) { Occurrence.create(value: 15, date: three_days_ago) }
    let(:run_thing) { Thing.create(name: 'run', default_value: 13) }
    let(:walk_thing) { Thing.create(name: 'run', default_value: 7) }
    let(:human) { create(:human)  }

    before do
      human.add_thing(run_thing)
      human.add_thing(walk_thing)
    end

    context 'when there is already an entry for today' do
      before do
        run_thing.add_occurrence(today_occurrence)
        walk_thing.add_occurrence(yesterday_occurrence)
      end

      it 'does nothing' do
        expect {
          human.backfill
        }.to change{ run_thing.occurrences.count }.by(0)
      end
    end

    context 'when the last occurrence was two days ago' do
      before do
        run_thing.add_occurrence(two_days_ago_occurrence)
        walk_thing.add_occurrence(three_days_ago_occurrence)
        walk_thing.add_occurrence(two_days_ago_occurrence)
      end

      it 'calls generate_default_occurrence_for_date on all Things for yesterday and today' do
        human.things.count.should == 2
        human.things.each do |thing|
          mock(thing).generate_default_occurrence_for_date(today)
          mock(thing).generate_default_occurrence_for_date(yesterday)
        end
        human.backfill
      end
    end
  end

  describe '.demo_instance' do
    context 'when the demo human has not been created' do
      subject { described_class.demo_instance }
      it { should be_a(Human) }
    end

    context 'when the demo human has already been created' do
      let(:demo_human) { Human.demo_instance }
      let(:demo_human_2) { Human.demo_instance }

      it 'returns the same instance each time' do
        demo_human.phone_number.should == demo_human_2.phone_number
      end
    end
  end

end
