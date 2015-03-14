require 'spec_helper'

describe DateParser do

  describe '#parse_date' do

    hash =  { 'Sunday Mar 15, 2015' => '2015-03-15',
              'Mar. 17'             => '2015-03-17',
              'OCTOBER 3'           => '2015-10-03'
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
