require 'spec_helper'

describe Util do

  describe '.range_of_date_strings' do
    let(:july_15_2006_at_noon) { Time.new(2006, 7, 15, 12) }

    context 'when offset is not passed in' do
      it 'returns dates starting "today"' do
        pretend_now_is(july_15_2006_at_noon) do
          array = described_class.range_of_date_strings(2)
          array.should == ['2006-07-15', '2006-07-16']
        end
      end
    end

    context 'when offset is passed in' do
      it 'returns dates starting in the future' do
        pretend_now_is(july_15_2006_at_noon) do
          array = described_class.range_of_date_strings(2, 1)
          array.should == ['2006-07-16', '2006-07-17']
        end
      end
    end
  end

  describe '.sha1' do
    context 'when text is nil' do
      it 'raises an error' do
        expect{
          described_class.sha1(nil)
        }.to raise_error(ArgumentError)
      end
    end

    context 'when text is a string' do
      it 'returns the sha1 hash' do
        described_class.sha1('triangles').should == '304a1e2f234f03d8786b9ee52c73f08670574139'
      end
    end
  end

  describe '.sha1_match?' do
    subject { described_class.sha1_match?(text, sha1) }
    let(:text) { 'boogie' }
    let(:sha1) { 'f4ede03457e31b690c246fae952317858735806a' }
    context 'when sha1 is the sha1 hash of text' do
      it { should be_truthy }
    end

    context 'when text and sha1 do not match' do
      let(:text) { 'something else' }
      it { should be_falsey }
    end

    context 'when sha1 is nil' do
      let(:sha1) { nil }
      it { should be_falsey }
    end

    context 'when text is nil' do
      let(:text) { nil }
      it { should be_falsey }
    end
  end

  describe '.hash_has_nonzero_value' do
    subject { described_class.hash_has_nonzero_value(hash) }
    context 'when all zeros' do
      let(:hash) { {a: 0, b: 0, c: 0} }
      it { should be_falsey }
    end

    context 'when some nonzero' do
      let(:hash) { {a: 0, b: 15, c: 0} }
      it { should be_truthy }
    end
  end

  describe '.is_browser?' do
    hash = { Opera: true,
             Aol: true,
             Firefox: true,
             nil: false,
             googlebot: false,
             yahoo: false }

    hash.each do |user_agent, expected_response|
      context "when user-agent is #{user_agent}" do
        it "returns #{expected_response}" do
          described_class.is_browser?(user_agent).should == expected_response
        end
      end
    end
  end
end

