require 'spec_helper'

describe DateParser do

  describe '#parse_date' do

    hash =  { 'Sunday Mar 15, 2015' => '2015-03-15',
              'Mar. 17'             => '2015-03-17',
              'Mar.17'              => '2015-03-17',
              'Mar    17'          => '2015-03-17',
              'OCTOBER 3'           => '2015-10-03',
              "on Friday, Nov 6 at 12:29pm so and so wrote:\nParty on March 3rd at my house" => '2015-03-03',
              "on Friday, Nov 6 at 12:29pm there's a party for those who wrote me"           => '2015-11-06',
              "March 2015 is a great year\nApril 5th there is a party"                       => '2015-04-05',
             }

    hash.each do |text, expected_date|
      context "when text is #{text}" do
        it "returns #{expected_date}" do
          message = described_class.new(text)
          message.parse.should == expected_date
        end
      end
    end
  end
end
