require 'spec_helper'

describe DateParser do
  let(:march_15) { Date.new(2015, 3, 15) }

  describe '#parse_date' do

    hash =  { 'Sunday Mar 15, 2015' => '2015-03-15',
      'Mar. 17'             => '2015-03-17',
      'Mar.17'              => '2015-03-17',
      'Mar    17'           => '2015-03-17',
      'OCTOBER 3'           => '2015-10-03',
      "on Friday, Nov 6 at 12:29pm so and so wrote:\nParty on March 3rd at my house" => '2015-03-03',
      "on Friday, Nov 6 at 12:29pm there's a party for those who wrote me"           => '2015-11-06',
      "March 2015 is a great year\nApril 5th there is a party"                       => '2015-04-05',
      "Through March 15th"       => nil,
      "starting March 15th"      => nil,
      "endIng March 15th"        => nil,
      "as soon  as March 15th"   => nil,
      "as early as March 15th"   => nil,
      "as late as March 15th"    => nil,
      "no later thaN March 15th" => nil,
      "by March  15th"           => nil,
      "until March 15th"         => nil,
      "before March 15th"        => nil,
      "due March 15th"           => nil,
    }

    hash.each do |text, expected_date|
      context "when text is #{text}" do
        it "returns #{expected_date}" do
          parser = described_class.new(text, march_15)
          parser.parse.should == expected_date
        end
      end
    end
  end

  describe '#parse_relative' do
    context 'when received_at is Monday, March 16 2015' do

      hash = {
        # Note that when today is monday, and you say "this monday", that doesn't count
        'This  monday'        => nil,
        'This  tuesday'       => '2015-03-17',
        'This  wednesday'     => '2015-03-18',
        'This  thursday'      => '2015-03-19',
        'This Coming  friday' => '2015-03-20',
        'This saturday'       => '2015-03-21',
        'This sunday'         => '2015-03-22',
      }

      hash.each do |text, expected_date|
        context "when text is #{text}" do
          it "returns #{expected_date}" do
            march_16 = Date.new(2015, 3, 16)
            march_16.strftime('%A').should == 'Monday'

            parser = described_class.new(text, march_16)
            parser.parse_relative.should == expected_date
          end
        end
      end
    end
  end
end
