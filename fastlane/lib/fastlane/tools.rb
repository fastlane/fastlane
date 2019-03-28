module Fastlane
  TOOLS = %i[
    fastlane
    pilot
    spaceship
    produce
    deliver
    frameit
    pem
    snapshot
    screengrab
    supply
    cert
    sigh
    match
    scan
    gym
    precheck
  ]

  # a list of all the config files we currently expect
  TOOL_CONFIG_FILES = %w[
    Appfile
    Deliverfile
    Fastfile
    Gymfile
    Matchfile
    Precheckfile
    Scanfile
    Screengrabfile
    Snapshotfile
  ]
end
