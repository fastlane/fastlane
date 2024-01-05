module Fastlane
  TOOLS = [
    :fastlane,
    :pilot,
    :spaceship,
    :produce,
    :deliver,
    :frameit,
    :pem,
    :snapshot,
    :screengrab,
    :supply,
    :cert,
    :sigh,
    :match,
    :scan,
    :gym,
    :precheck,
    :trainer
  ]

  # a list of all the config files we currently expect
  TOOL_CONFIG_FILES = [
    "Appfile",
    "Deliverfile",
    "Fastfile",
    "Gymfile",
    "Matchfile",
    "Precheckfile",
    "Scanfile",
    "Screengrabfile",
    "Snapshotfile"
  ]

  TOOL_ALIASES = {
    "get_certificates": "cert",
    "upload_to_app_store": "deliver",
    "frame_screenshots": "frameit",
    "build_app": "gym",
    "build_ios_app": "gym",
    "build_mac_app": "gym",
    "sync_code_signing": "match",
    "get_push_certificate": "pem",
    "check_app_store_metadata": "precheck",
    "capture_android_screenshots": "screengrab",
    "get_provisioning_profile": "sigh",
    "capture_ios_screenshots": "snapshot",
    "upload_to_play_store": "supply"
  }
end
