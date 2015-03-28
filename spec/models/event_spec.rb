require 'spec_helper'

describe Event do
  describe '.load' do
    it 'loads events' do
      described_class.all.map(&:delete)
      described_class.load
      (described_class.count > 15).should == true
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
end
