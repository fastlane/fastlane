class String
  def fastlane_class
    split('_').collect!(&:capitalize).join
  end
end
