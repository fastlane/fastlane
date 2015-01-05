require 'json'
require 'mini_magick'
require 'frameit/version'
require 'frameit/helper'
require 'frameit/frame_converter'
require 'frameit/editor'
require 'frameit/update_checker'
require 'frameit/dependency_checker'
require 'deliver'

# Third Party code
require 'colored'

module Frameit
  Frameit::UpdateChecker.verify_latest_version
  Frameit::DependencyChecker.check_dependencies
end
