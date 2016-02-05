describe Fastlane do
  describe Fastlane::Helper::LockerHelper do
    describe "LockerHelper tests" do
      before do
        @lh = Fastlane::Helper::LockerHelper.new
        @lh.lock_file_name = "/tmp/fastlane_test.lock"

        if File.exist?(@lh.lock_file_name)
          File.delete(@lh.lock_file_name)
        end
      end

      it "verifies that the recheck sleep time is 30s" do
        expect(Fastlane::Helper::LockerHelper.lock_recheck_sleep_time).to eq(30)
      end

      it "validates max_wait_time" do
        expect(Fastlane::Helper::LockerHelper.max_wait_time).to eq(60 * 2 * (2 * Fastlane::Helper::LockerHelper.lock_recheck_sleep_time))
      end

      it "validates current_pid" do
        expect(Fastlane::Helper::LockerHelper.current_pid).to eq(Process.pid)
      end

      it "validates locking_pid" do
        File.open(@lh.lock_file_name, "w") do |f|
          f.write(12)
          f.close
        end

        expect(@lh.locking_pid).to eq(12)
      end

      it "validates create_lock" do
        @lh.create_lock

        expect(Integer(File.read(@lh.lock_file_name))).to eq(Process.pid)
      end

      it "validates proceed_condition lock file does not exist and waited time is less than max" do
        @lh.waited_time = 0

        expect(@lh.proceed_condition).to eq(true)
      end

      it "validates proceed_condition lock file exist and waited time is less than max" do
        @lh.create_lock
        @lh.waited_time = 0

        expect(@lh.proceed_condition).to eq(false)
      end

      it "validates that the locking process existance is detected correctly, locking process exist" do
        @lh.create_lock
        @lh.check_locking_process_existance
      end

      it "validates that the locking process existance is detected correctly, locking process does not exist" do
        File.open(@lh.lock_file_name, "w") do |f|
          f.write(59800)
          f.close
        end

        expect do
          @lh.check_locking_process_existance
        end.to raise_error(/No such process/)
      end

      it "validates lock file path is generated as expected" do
        expect(Fastlane::Helper::LockerHelper.lock_file_path("test")).to eq(@lh.lock_file_name)
      end

      it "validates lock_exec works properly when no locking exists" do
        my_test_value = 20
        locker = Fastlane::Helper::LockerHelper.lock_exec("test") do
          my_test_value = 30
          expect(File.exist?(@lh.lock_file_name)).to eq(true)
        end

        expect(locker.waited_time == 0).to eq(true)
        expect(my_test_value).to eq(30)
        expect(File.exist?(@lh.lock_file_name)).to eq(false)
      end

      it "validates lock_exec works properly when some locking exists, locking process exists, and waited max time" do
        File.open(@lh.lock_file_name, "w") do |f|
          f.write(Process.pid)
          f.close
        end

        my_test_value = 20
        locker = Fastlane::Helper::LockerHelper.lock_exec("test") { my_test_value = 30 }

        expect(locker.waited_time > 0).to eq(true)
        expect(my_test_value).to eq(30)
        expect(File.exist?(@lh.lock_file_name)).to eq(false)
      end

      it "validates lock_exec works properly when some locking exists, locking process does not exists, and waited max time" do
        File.open(@lh.lock_file_name, "w") do |f|
          f.write(59800)
          f.close
        end

        my_test_value = 20
        locker = Fastlane::Helper::LockerHelper.lock_exec("test") do
          my_test_value = 30
        end

        expect(locker.waited_time == 0).to eq(true)
        expect(my_test_value).to eq(30)
        expect(File.exist?(@lh.lock_file_name)).to eq(false)
      end
    end
  end
end
