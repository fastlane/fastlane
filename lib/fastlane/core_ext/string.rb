class String
  def classify
    split('_').collect!(&:capitalize).join
  end
end