#!/usr/bin/env ruby
require 'match'

# CLI to encrypt/decrypt files using fastlane match encryption layer

def usage
  puts("USAGE: [encrypt|decrypt] input_path password [output_path]")
  exit(-1)
end

if ARGV.count < 3 || ARGV.count > 4
  usage
end

method_name = ARGV.shift
unless ['encrypt', 'decrypt'].include?(method_name)
  usage
end

begin
  Match::Encryption::MatchFileEncryption.new.send(method_name, *ARGV)
rescue => e
  puts("ERROR #{method_name}ing. [#{e}]. Check your password")
  usage
end
