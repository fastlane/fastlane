require_relative 'spaceship/globals'
require_relative 'spaceship/base'
require_relative 'spaceship/client'
require_relative 'spaceship/provider'
require_relative 'spaceship/launcher'

# Dev Portal
require_relative 'spaceship/portal/portal'
require_relative 'spaceship/portal/spaceship'

# App Store Connect
require_relative 'spaceship/tunes/tunes'
require_relative 'spaceship/tunes/spaceship'
require_relative 'spaceship/test_flight'
require_relative 'spaceship/connect_api'
require_relative 'spaceship/spaceauth_runner'

require_relative 'spaceship/module'

# Support for legacy wrappers
require_relative 'spaceship/portal/legacy_wrapper'
require_relative 'spaceship/tunes/legacy_wrapper'

# For basic user inputs
require 'highline/import'
require 'colored'
