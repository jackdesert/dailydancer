require 'spec_helper'

include ApplicationHelper

describe ApplicationHelper do
  describe '#insert_hyperlinks' do
    context 'when there is no hyperlink' do
      it 'returns the original' do
        original = 'hi'
        insert_hyperlinks(original).should == original
      end

      context 'but there is a colon after a word' do
        it 'returns the original' do
        original = 'from: me'
        insert_hyperlinks(original).should == original
        end
      end
    end

    context 'when there is one hyperlink' do
      context 'when there is no period after the hyperlink' do
        it 'inserts an anchor' do
          original = 'Go to http://facebook.com '
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a> "
          insert_hyperlinks(original).should == expected
        end
      end

      context 'when there is a period after the hyperlink' do
        it 'inserts an anchor but leaves the period outside the hyperlink' do
          original = 'Go to http://facebook.com.'
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a>."
        end
      end
    end

    context 'when there are two hyperlinks' do
      context 'when the second hyperlink is a subset of the first' do
        it 'inserts both anchors properly' do
          original = 'Go to http://facebook.com '
          expected = "Go to <a href='http://facebook.com' target='_blank'>http://facebook.com</a> "
          insert_hyperlinks(original).should == expected
        end
      end

      context 'when there is a period after the hyperlink' do
        it 'inserts an anchor but leaves the period outside the hyperlink' do
          original = 'http://hi.com/1 and http://hi.com/'
          expected = "<a href='http://hi.com/1' target='_blank'>http://hi.com/1</a> and <a href='http://hi.com/' target='_blank'>http://hi.com/</a>"
          insert_hyperlinks(original).should == expected
        end
      end
    end
  end

  describe '#build_etag' do
    it 'returns a string' do
      build_etag.class.should == String
    end

    it 'does not contain a comma' do
      build_etag.match(',').should be_nil
    end
  end

  describe 'root_url' do
    after do
      ApplicationHelper::RACK_ENV = 'test'
    end

    context 'test environment' do
      it 'is a valid url' do
        root_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        root_url.should == 'http://dancer-local.com:9292'
      end
    end

    context 'production environment' do
      before do
        ApplicationHelper::RACK_ENV = 'production'
      end

      it 'is a valid url' do
        root_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        root_url.should == 'http://pdxdailydancer.com'
      end
    end
  end

  describe 'faq_url' do
    after do
      ApplicationHelper::RACK_ENV = 'test'
    end

    context 'test environment' do
      it 'is a valid url' do
        faq_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        faq_url.should == 'http://dancer-local.com:9292/faq'
      end
    end

    context 'production environment' do
      before do
        ApplicationHelper::RACK_ENV = 'production'
      end

      it 'is a valid url' do
        faq_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        faq_url.should == 'http://pdxdailydancer.com/faq'
      end
    end
  end

  describe 'status_url' do
    after do
      ApplicationHelper::RACK_ENV = 'test'
    end

    context 'test environment' do
      it 'is a valid url' do
        status_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        status_url.should == 'http://status.dancer-local.com:9292'
      end
    end

    context 'production environment' do
      before do
        ApplicationHelper::RACK_ENV = 'production'
      end

      it 'is a valid url' do
        status_url.match(URI::ABS_URI).should_not be_nil
      end

      it 'points to the canonical location' do
        status_url.should == 'http://status.pdxdailydancer.com'
      end
    end
  end

end

























