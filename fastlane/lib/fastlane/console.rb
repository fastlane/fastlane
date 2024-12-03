require 'irb'

module Fastlane
  # Opens an interactive developer console
  class Console
    def self.execute(args, options)
      ARGV.clear
      IRB.setup(nil)
      @irb = IRB::Irb.new(nil)
      IRB.conf[:MAIN_CONTEXT] = @irb.context
      IRB.conf[:PROMPT][:FASTLANE] = IRB.conf[:PROMPT][:SIMPLE].dup
      IRB.conf[:PROMPT][:FASTLANE][:RETURN] = "%s\n"
      @irb.context.prompt_mode = :FASTLANE
      @irb.context.workspace = IRB::WorkSpace.new(binding)
      trap('INT') do
        @irb.signal_handle
      end

      UI.message('Welcome to fastlane interactive!')

      catch(:IRB_EXIT) { @irb.eval_input }
    end
  end
end
