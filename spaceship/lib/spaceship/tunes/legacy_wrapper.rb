require_relative 'app_version'
require_relative 'app_submission'
require_relative 'application'
require_relative 'members'
require_relative '../portal/persons'

module Spaceship
  AppVersion = Spaceship::Tunes::AppVersion
  AppSubmission = Spaceship::Tunes::AppSubmission
  Application = Spaceship::Tunes::Application
  Members = Spaceship::Tunes::Members
  Persons = Spaceship::Portal::Persons
end
