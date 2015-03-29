require 'spec_helper'

describe Event do
  before do
    # Make sure this is not set so that all tests actually fire
    described_class.klass_last_loaded_at = nil
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
    end
  end

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
      event.address.should == '4920 NE 55th Ave Portland OR (behind yellow house)'
    end
  end
end
