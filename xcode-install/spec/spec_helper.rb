require 'coveralls'
Coveralls.wear!

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)

ENV['DELIVER_USER'] = 'xcversion'
ENV['DELIVER_PASSWORD'] = '12345password'

require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'xcode/install'
