module SitePrism
  class AddressableQueryProcessor
    def self.restore(name, value)
      return value.inject({}) { |h, (k, v)| h[k] = v.gsub(/\+/, ' ') ; h } if name == 'query'
      return value
    end

    def self.match(_name)
      return '.*'
    end
  end
end
