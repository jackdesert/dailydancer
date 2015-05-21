require 'spec_helper'

describe Event do
  before do
    # Make sure this is not set so that all tests actually fire
    described_class.klass_last_loaded_at = nil
  end

  describe 'Default values' do
    it 'has empty string for :occurs_on' do
      described_class.create.occurs_on.should == ''
    end
  end


  describe '#time_formatted' do
    let(:event) { described_class.new(day_of_week: 'friday') }
    hash = { '10-12pm' => 'Fridays 10-12pm',
             '1st and 3rd Fridays 2:30-5pm' => '1st and 3rd Fridays 2:30-5pm'}

    hash.each do |time, time_formatted|
      context "when time is #{time}" do
        it "returns #{time_formatted}" do
          event.time = time
          event.time_formatted.should == time_formatted
        end
      end
    end
  end

  describe '.which_occurrence' do
    hash = { '2015-04-01' => 1,
             '2015-04-02' => 1,
             '2015-04-03' => 1,
             '2015-04-04' => 1,
             '2015-04-05' => 1,
             '2015-04-06' => 1,
             '2015-04-07' => 1,
             '2015-04-08' => 2,
             '2015-04-09' => 2,
             '2015-04-10' => 2,
             '2015-04-11' => 2,
             '2015-04-12' => 2,
             '2015-04-13' => 2,
             '2015-04-14' => 2,
             '2015-04-15' => 3,
             '2015-04-16' => 3,
             '2015-04-17' => 3,
             '2015-04-18' => 3,
             '2015-04-19' => 3,
             '2015-04-20' => 3,
             '2015-04-21' => 3,
             '2015-04-22' => 4,
             '2015-04-23' => 4,
             '2015-04-24' => 4,
             '2015-04-25' => 4,
             '2015-04-26' => 4,
             '2015-04-27' => 4,
             '2015-04-28' => 4,
             '2015-04-29' => 5,
             '2015-04-30' => 5 }
    hash.each do |date_string, occurrence|
      context "when date_string is #{date_string}" do
        it "returns #{occurrence}" do
          date = Date.parse(date_string)
          described_class.which_occurrence(date).should == occurrence
        end
      end
    end
  end

  describe '#address' do
    it 'pulls from location_url' do
      event = described_class.new(location_url: 'http://maps.google.com/maps?q=4920+NE+55th+Ave+Portland+OR+(behind+yellow+house)')
      event.address.should == '4920 NE 55th Ave Portland OR'
    end
  end

  describe '.been_a_while?' do
    let(:jan_1_2000_at_noon) { Time.new(2000, 1, 1, 0, 0) }

    context 'when klass_last_loaded_at is not set' do
      before do
        described_class.klass_last_loaded_at = nil
      end

      it 'returns true' do
        pretend_now_is jan_1_2000_at_noon do
          described_class.been_a_while?.should == true
        end
      end
    end

    context 'when klass_last_loaded_at is set' do
      before do
        described_class.klass_last_loaded_at = jan_1_2000_at_noon
      end

      context 'when more than an hour later' do
        it 'returns true' do
          pretend_now_is jan_1_2000_at_noon + 70.minutes do
            described_class.been_a_while?.should == true
          end
        end
      end

      context 'when less than an hour later' do
        it 'returns false' do
          pretend_now_is jan_1_2000_at_noon + 30.minutes do
            described_class.been_a_while?.should == false
          end
        end
      end
    end
  end

  # Redefined equality operator
  describe '#==' do

    let(:first_event)   { described_class.create }
    let(:attributes)    { attrs = first_event.to_hash; attrs.delete(:id); attrs }
    let(:second_event)  { described_class.new(attributes) }


    subject { first_event == second_event }

    context 'when one column differs' do
      columns_to_compare = [:day_of_week, :time, :name, :url, :hostess,  :location, :location_url, :occurs_on]

      columns_to_compare.each do |column|
        context "when #{column} is different" do
          before do
            second_event.send("#{column}=", 'something_else')
          end
          it { should == false }
        end
      end
    end

    context 'when all columns match' do
      it { should == true }
    end

    context 'when scraped_at is the only column that is different' do
      before do
        second_event.scraped_at = Time.new(1999, 1, 1, 12, 34)
      end
      it { should == true }
    end
  end

  describe '.at_least_one_event_changed?' do
    let!(:first_event)  { described_class.create }
    let!(:second_event) { described_class.create }
    let(:attributes)    { attrs = first_event.to_hash; attrs.delete(:id); attrs }
    let(:third_event)   { described_class.new(attributes) }
    let(:fourth_event)  { described_class.new(attributes) }
    let(:new_events)    { [third_event, fourth_event] }
    subject             { described_class.at_least_one_event_changed?(new_events) }

    context 'when all events are the same' do
      it { should == false }
    end

    context 'when one event is not the same' do
      before do
        third_event.name = 'Spooning'
      end

      it { should == true }
    end
  end

  describe '.load' do

    let(:minimum_to_create) { 15 }
    it 'loads events' do
      described_class.all.map(&:delete)

      # Keep track of the largest id
      previous_largest_id = described_class.last.try(:id).to_i

      described_class.load

      largest_id = described_class.last.try(:id).to_i

      # This makes sure than new entries have actually been written
      ((largest_id - previous_largest_id) > minimum_to_create).should == true

      # This makes sure that events still exist
      (described_class.count > minimum_to_create).should == true

      # make sure it does not load any more events if none have changed
      described_class.load
      new_largest_id = described_class.last.try(:id).to_i
      new_largest_id.should == largest_id
    end
  end

  # Note this test is last so it does not interfere with other tests
  describe '.load_in_thread_if_its_been_a_while' do
    it 'creates a file' do
      FileUtils.rm_f(described_class::SAVED_WEB_PAGE)
      FileUtils.rm_f(described_class::SAVED_WEB_PAGE_TEMP)

      File.exist?(described_class::SAVED_WEB_PAGE_TEMP).should == false
      File.exist?(described_class::SAVED_WEB_PAGE).should == false

      described_class.load_in_thread_if_its_been_a_while
      counter = 10

      # Give it 20 seconds to return
      while counter > 0
        sleep 1
        counter = 0 if File.exist?(described_class::SAVED_WEB_PAGE)
        counter -= 1
      end
      File.exist?(described_class::SAVED_WEB_PAGE_TEMP).should == true
      File.exist?(described_class::SAVED_WEB_PAGE).should == true
    end
  end
end


























