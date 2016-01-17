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
    subject { described_class.is_browser?(user_agent) }

    context 'known browsers' do
      context 'when AOL 9.7' do
        let (:user_agent) { 'Mozilla/5.0 (compatible; MSIE 9.0; AOL 9.7; AOLBuild 4343.19; Windows NT 6.1; WOW64; Trident/5.0; FunWebProducts)' }
        it { should == true }
      end

      context 'when Opera 12.16' do
        let (:user_agent) { 'Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/12.16' }
        it { should == true }
      end

      context 'when iPhone 5' do
        let (:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3' }
        it { should == true }
      end

      context 'when Android WebKit' do
        let (:user_agent) { 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' }
        it { should == true }
      end

      context 'when Chrome' do
        let (:user_agent) { 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36' }
        it { should == true }
      end

      context 'when Safari 7' do
        let (:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A' }
        it { should == true }
      end

      context 'when dolphin' do
        let (:user_agent) { '"Mozilla/5.0 (Linux; U; Android 5.0.1; en-us; Nexus 4 Build/LRX22C) AppleWebKit/537.16 (KHTML, like Gecko) Version/4.0 Mobile Safari/537.16"' }
        it { should == true }
      end

      context 'when puffin' do
        let (:user_agent) { 'Mozilla/5.0 (X11; U; Linux x86_64; zh-TW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.114 Safari/537.36 Puffin/3.7.0IT' }
        it { should == true }
      end

      context 'when mercury' do
        let (:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mercury/7.2 Mobile/9B206 Safari/7534.48.3' }
        it { should == true }
      end
    end


    context 'known bots' do
      # Note that many browsers and bots reference Mozilla/x.0
      # Note that many bots use the word 'compatible'
      context 'when GoogleBot 2.1' do
        let (:user_agent) { 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' }
        it { should == false }
      end

      context 'when Bing' do
        let (:user_agent) { 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)' }
        it { should == false }
      end

      context 'when Yahoo Slurp' do
        let (:user_agent) { 'Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)' }
        it { should == false }
      end

      context 'when Speedy Spider' do
        let (:user_agent) { 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) Speedy Spider (http://www.entireweb.com/about/search_tech/speedy_spider/)' }
        it { should == false }
      end

      context 'when Seekbot' do
        let (:user_agent) { 'Seekbot/1.0 (http://www.seekbot.net/bot.html) RobotsTxtFetcher/1.2' }
        it { should == false }
      end
    end

  end

  describe '.by_date_empty' do
    context 'when num_days is 2 and offset is 1' do
      let(:valentines_day_2015_at_noon) { Time.new(2015, 2, 14, 12) }

      it 'returns empty arrays for tomorrow and the next day' do
        pretend_now_is(valentines_day_2015_at_noon) do
          described_class.by_date_empty(2, 1).should == { '2015-02-15' => [], '2015-02-16' => [] }
        end
      end
    end
  end
end

