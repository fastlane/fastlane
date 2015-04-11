class String
  def fastlane_class
    split('_').collect!(&:capitalize).join
  end

  def fastlane_uncapitalize 
    self[0, 1].downcase + self[1..-1]
  end
end
