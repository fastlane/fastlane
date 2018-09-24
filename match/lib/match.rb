require_relative 'match/options'
require_relative 'match/runner'
require_relative 'match/nuke'
require_relative 'match/utils'
require_relative 'match/table_printer'
require_relative 'match/generator'
require_relative 'match/setup'
require_relative 'match/spaceship_ensure'
require_relative 'match/change_password'
require_relative 'match/module'

# Implement all available implementations

# Storage
require_relative 'match/storage/interface'
require_relative 'match/storage/git_storage'

# Encryption
require_relative 'match/encryption/interface'
require_relative 'match/encryption/openssl'
