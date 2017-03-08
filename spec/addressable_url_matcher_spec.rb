require 'spec_helper'

describe SitePrism::AddressableUrlMatcher do
  describe '#matches?' do
    let(:url) { 'https://joe:bleep@bazzle.com:8443/foos/22/bars/12?junk=janky&param=some+value#middle' }

    it 'matches on templated scheme' do
      expect_matches('{scheme}://bazzle.com').to eq true
    end

    it 'matches on static scheme' do
      expect_matches('https://bazzle.com').to eq true
    end

    it 'fails on bad scheme' do
      expect_matches('ftp://bazzle.com').to eq false
    end

    it 'matches on templated user' do
      expect_matches('//{user}@bazzle.com').to eq true
    end

    it 'matches on static user' do
      expect_matches('//joe@bazzle.com').to eq true
    end

    it 'fails on bad user' do
      expect_matches('//bob@bazzle.com').to eq false
    end

    it 'matches on templated password' do
      expect_matches('//joe:{password}@bazzle.com').to eq true
    end

    it 'matches on static password' do
      expect_matches('//joe:bleep@bazzle.com').to eq true
    end

    it 'fails on bad password' do
      expect_matches('//joe:bloop@bazzle.com').to eq false
    end

    it 'matches on templated host' do
      expect_matches('//{host}').to eq true
    end

    it 'matches on static host' do
      expect_matches('//bazzle.com').to eq true
    end

    it 'fails on bad host' do
      expect_matches('//bungle.com').to eq false
    end

    it 'raises on templated port' do
      expect { matches? '//bazzle.com:{port}' }.to raise_error SitePrism::InvalidUrlMatcher
    end

    it 'matches on static port' do
      expect_matches('//bazzle.com:8443').to eq true
    end

    it 'fails on bad port' do
      expect_matches('//bungle.com:7654').to eq false
    end
    it 'matches on templated path' do
      expect_matches('/foos/{foo_id}/bars{/bar_id}').to eq true
    end

    it 'matches on static path' do
      expect_matches('/foos/22/bars/12').to eq true
    end

    it 'fails on bad path' do
      expect_matches('/foos/22/bars/123').to eq false
    end

    it 'matches on templated query' do
      expect_matches('/foos/22/bars/12{?query*}').to eq true
    end

    it 'matches on static query' do
      expect_matches('/foos/22/bars/12?junk=janky&param=some+value').to eq true
    end

    it 'fails on bad query' do
      expect_matches('/foos/22/bars/123?junk=delightful').to eq false
    end

    it 'matches on templated fragment' do
      expect_matches('{#fragment}').to eq true
    end

    it 'matches on static fragment' do
      expect_matches('#middle').to eq true
    end

    it 'fails on bad fragment' do
      expect_matches('#muddle').to eq false
    end

    it 'matches everything at once' do
      expect_matches('{scheme}://{user}:{password}@{host}:8443/foos{/foo_id}/bars{/id}{?params*}#middle').to eq true
    end

    it 'matches on no path' do
      expect_matches('//bazzle.com').to eq true
    end

    it "doesn't match on root path" do
      expect_matches('//bazzle.com/').to eq false
    end

    it 'matches with single mappings' do
      expect_matches('//bazzle.{tld}', tld: 'com').to eq true
    end

    it 'matches with string keys on expected_mappings' do
      expect_matches('//bazzle.{tld}', 'tld' => 'com').to eq true
    end

    it 'fails on incorrect mappings' do
      expect_matches('//bazzle.{tld}{/path*}', tld: 'org').to eq false
    end

    it 'matches with partially specified mappings' do
      expect_matches('//bazzle.{tld}{/path*}', tld: 'com').to eq true
    end

    it 'fails on overspecified mappings' do
      expect_matches('{/path*}', tld: 'com').to eq false
    end

    it 'matches with completely specified mappings' do
      expect_matches('/foos/{foo_id}/bars/{bar_id}', foo_id: '22', bar_id: '12').to eq true
    end

    it 'casts numbers to strings for comparison' do
      expect_matches('/foos/{foo_id}/bars/{bar_id}', foo_id: 22, bar_id: 12).to eq true
    end

    it 'matches on correct regular expressions' do
      expect_matches('/foos/{foo_id}/bars/{bar_id}', foo_id: /2\d/, bar_id: 12).to eq true
    end

    it 'fails on incorrect regular expressions' do
      expect_matches('/foos/{foo_id}/bars/{bar_id}', foo_id: /2\d\d/, bar_id: 12).to eq false
    end

    def expect_matches(*args)
      expect(matches?(*args))
    end

    def matches?(*args)
      expected_mappings = args.last.is_a?(::Hash) ? args.pop : {}
      pattern = args.first || raise('Must specify a pattern for matches?')
      SitePrism::AddressableUrlMatcher.new(pattern).matches?(url, expected_mappings)
    end
  end
end
