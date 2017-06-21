module Precheck
  # each attribute on a app version is a single item.
  # for example: .name, .keywords, .description, will all have a single item to represent them
  # which includes their name and a more user-friendly name we can use to print out information
  class ItemToCheck
    attr_accessor :item_name
    attr_accessor :friendly_name
    attr_accessor :is_optional

    def initialize(item_name, friendly_name, is_optional = false)
      @item_name = item_name
      @friendly_name = friendly_name
      @is_optional = is_optional
    end

    def item_data
      not_implemented(__method__)
    end

    def inspect
      "#{self.class}(friendly_name: #{@friendly_name}, data: #{@item_data})"
    end

    def to_s
      "#{self.class}: #{item_name}: #{friendly_name}"
    end
  end

  # if the data point we want to check is a text field (like 'description'), we'll use this object to encapsulate it
  # this includes the text, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class TextItemToCheck < ItemToCheck
    attr_accessor :text

    def initialize(text, item_name, friendly_name, is_optional = false)
      @text = text
      super(item_name, friendly_name, is_optional)
    end

    def item_data
      return text
    end
  end

  # if the data point we want to check is a URL field (like 'marketing_url'), we'll use this object to encapsulate it
  # this includes the url, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class URLItemToCheck < ItemToCheck
    attr_accessor :url

    def initialize(url, item_name, friendly_name, is_optional = false)
      @url = url
      super(item_name, friendly_name, is_optional)
    end

    def item_data
      return url
    end
  end
end
