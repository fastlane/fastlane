describe FastlaneCore do
  describe FastlaneCore::Project do
    describe "Project.run_command" do
      def count_processes(text)
        `ps -aef | grep #{text} | grep -v grep | wc -l`.to_i
      end

      it "runs simple commands" do
        cmd = 'echo HO' # note: this command is deliberately not using `"` around `HO` as `echo` would echo those back on Windows
        expect(FastlaneCore::Project.run_command(cmd)).to eq("HO\n")
      end

      it "runs more complicated commands" do
        cmd = "ruby -e 'sleep 0.1; puts \"HI\"'"
        expect(FastlaneCore::Project.run_command(cmd)).to eq("HI\n")
      end

      it "should timeouts and kills" do
        text = "FOOBAR" # random text
        count = count_processes(text)
        cmd = "ruby -e 'sleep 3; puts \"#{text}\"'"
        expect do
          FastlaneCore::Project.run_command(cmd, timeout: 1)
        end.to raise_error(Timeout::Error)

        # on mac this before only partially works as expected
        if FastlaneCore::Helper.mac?
          # this shows the current implementation issue
          # Timeout doesn't kill the running process
          # i.e. see fastlane/fastlane_core#102
          expect(count_processes(text)).to eq(count + 1)
          sleep(5)
          expect(count_processes(text)).to eq(count)
          # you would be expected to be able to see the number of processes go back to count right away.
        end
      end

      it "retries and kills" do
        text = "NEEDSRETRY"
        cmd = "ruby -e 'sleep 3; puts \"#{text}\"'"

        expect(FastlaneCore::Project).to receive(:`).and_call_original.exactly(4).times

        expect do
          FastlaneCore::Project.run_command(cmd, timeout: 0.2, retries: 3)
        end.to raise_error(Timeout::Error)
      end
    end
  end
end
