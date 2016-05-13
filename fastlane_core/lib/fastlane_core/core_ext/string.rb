class String
  def fastlane_class
    split('_').collect!(&:capitalize).join
  end

  def fastlane_module
    self == "pem" ? 'PEM' : self.fastlane_class
  end

  def fastlane_underscore
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr("-", "_").
      downcase
  end
end
