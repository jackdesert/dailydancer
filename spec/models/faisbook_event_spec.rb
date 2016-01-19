require 'spec_helper'

describe FaisbookEvent do

  def sample_json_event
    {"description"=>"cool description",
     "end_time"=>"2016-01-18T17:00:00-0800",
     "name"=>"cool name",
     "place"=>
      {"name"=>"cool location",
       "location"=>
        {"city"=>"Portland",
         "country"=>"United States",
         "latitude"=>45.5231514,
         "longitude"=>-122.6553192,
         "state"=>"OR",
         "street"=>"64 NE 12th Ave",
         "zip"=>"97232"},
       "id"=>"375295060291"},
     "start_time"=>"2016-01-18T13:00:00-0800",
     "id"=>"724793004324241"}
  end

  describe '.scrape_faisbook_ids_from_mobile_optimized' do
    context 'happy path' do
      it 'returns a list of integers' do
        ids = described_class.scrape_faisbook_ids_from_mobile_optimized
        ids.each do |id|
          id.match(/\A\d+\z/).should_not be_nil
        end
      end
    end
  end

  describe '.fetch_event_details_from_api' do
    context 'happy path' do
      it 'returns json objects' do
        result = described_class.fetch_event_details_from_api
      end
    end
  end

  describe '.save_event' do
    context 'happy path' do
      it 'saves event' do
        described_class.save_event(sample_json_event)
        event = described_class.first

        event.name.should == 'cool name'
        event.description.should == 'cool description'
        event.address.should == '64 NE 12th Ave Portland OR'
        event.start_time.should == '2016-01-18T13:00:00-0800'
        event.end_time.should == '2016-01-18T17:00:00-0800'
        event.date.should == '2016-01-18'
      end
    end

    context 'when the event already exists in our database' do
      context 'when the event has changed' do
        it 'updates the event' do
          described_class.save_event(sample_json_event)
          sleep 1
          described_class.save_event(sample_json_event.merge('name' => 'different name'))

          described_class.count.should == 1
          event = described_class.first
          event.name.should == 'different name'
          event.updated_at.should_not == event.created_at
        end
      end

      context 'when the event has NOT changed' do
        it 'does not update :updated_at' do
          described_class.save_event(sample_json_event)
          sleep 1
          described_class.save_event(sample_json_event)
          described_class.count.should == 1
          described_class.first.created_at.should == described_class.first.updated_at
        end
      end
    end
  end

  describe '.fetch_and_save_newly_posted' do
    it 'populates the database' do
      described_class.fetch_and_save_newly_posted
      described_class.count.should_not == 0
    end
  end
end

