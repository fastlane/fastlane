require 'irb'

module Fastlane
  # Opens an interactive developer console
  class Console
    def self.execute(args, options)
      ARGV.clear
      IRB.setup(nil)
      workspace = IRB::WorkSpace.new(binding)
      @irb = IRB::Irb.new(workspace)
      IRB.conf[:MAIN_CONTEXT] = @irb.context
      IRB.conf[:PROMPT][:FASTLANE] = IRB.conf[:PROMPT][:SIMPLE].dup
      IRB.conf[:PROMPT][:FASTLANE][:RETURN] = "%s\n"
      @irb.context.prompt_mode = :FASTLANE
      trap('INT') do
        @irb.signal_handle
      end

      UI.message('Welcome to fastlane interactive!')

      catch(:IRB_EXIT) { @irb.eval_input }
    end
  end
end
