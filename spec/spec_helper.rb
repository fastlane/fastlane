require_relative '../lib/pem'
require 'pry'

def fixture_path(file)
  File.join(File.expand_path('../fixtures', __FILE__), file)
end
