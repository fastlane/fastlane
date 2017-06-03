module Review
  class ItemToCheck
    attr_accessor :item_name
    attr_accessor :friendly_name

    def initialize(item_name, friendly_name)
      @item_name = item_name
      @friendly_name = friendly_name
    end
  end
  # if the data point we want to check is a text field (like 'description'), we'll use this object to encapsulate it
  # this includes the text, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class TextItemToCheck < ItemToCheck
    attr_accessor :text

    def initialize(text, item_name, friendly_name)
      @text = text
      super(item_name, friendly_name)
    end

    def to_s
      @item_name
    end

    def inspect
      "#{self.class}(friendly_name: #{@friendly_name}, text: #{@text})"
    end
  end

  # if the data point we want to check is a URK field (like 'marketing_url'), we'll use this object to encapsulate it
  # this includes the url, the property name, and what that name maps to in plain english so that we can print out nice, friendly messages.
  class URLItemToCheck < ItemToCheck
    attr_accessor :url

    def initialize(url, item_name, friendly_name)
      @url = url
      super(item_name, friendly_name)
    end

    def to_s
      @item_name
    end

    def inspect
      "#{self.class}(friendly_name: #{@friendly_name}, url: #{@url})"
    end
  end
end
