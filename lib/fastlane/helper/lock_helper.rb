module Fastlane
  module Helper
    # Helps to make sure that only one instance of action(s)
    # is(are) executed on the same machine at the same time
    class LockerHelper

      attr_accessor :waited_time
      attr_accessor :lock_name
      attr_accessor :lock_file_name

      # wait 30 seconds between checks
      def self.lock_recheck_sleep_time
        30
      end

      def self.max_wait_time
        60 * 2 * (2 * LockerHelper.lock_recheck_sleep_time)
      end

      def self.current_pid
        Process.pid
      end

      def locking_pid
        # get the current locking process pid from the lock file
        Integer(File.read(lock_file_name))
      end

      def create_lock
        File.open(lock_file_name, "w") do |f|
          f.write(LockerHelper.current_pid)
          f.close
        end
      end

      def remove_lock
        File.delete(lock_file_name)
      end

      def wait_retry
        unless Helper.is_test?
          sleep LockerHelper.lock_recheck_sleep_time
        end

        @waited_time += LockerHelper.lock_recheck_sleep_time
      end

      def proceed_condition
        !File.exist?(lock_file_name) || @waited_time >= LockerHelper.max_wait_time
      end

      def check_locking_process_existance
        Process.getpgid(locking_pid)
      end

      def self.lock_file_path(lock_name)
        "/tmp/fastlane_#{lock_name}.lock"
      end

      def self.lock_exec(name, &block)
        locker = LockerHelper.new
        locker.waited_time = 0
        locker.lock_file_name = LockerHelper.lock_file_path(name)

        Helper.log.info "[LOCKER] Locking execution context '#{locker.lock_name}' -> '#{locker.lock_file_name}' ..."

        loop do
          # exit the loop if:
          # - lock_file does not exist
          # or - waited more than 2h, that process must be hung somewhere
          break if locker.proceed_condition

          # check whether the locking process still exists
          # break the loop if it doesn't exits or we waited too much time
          begin
            locker.check_locking_process_existance
          rescue Errno::ESRCH
            locker.remove_lock
            break
          end

          tries = 1 + locker.waited_time / LockerHelper.lock_recheck_sleep_time
          Helper.log.info "[LOCKER] Waiting #{LockerHelper.lock_recheck_sleep_time} seconds for execution context '#{locker.lock_name}' to unlock. Try ##{tries}."

          # wait a little bit, then try again
          locker.wait_retry
        end

        # create the lock file with the current process pid
        locker.create_lock

        Helper.log.info "[LOCKER] Locked execution context '#{locker.lock_name}' -> '#{locker.lock_file_name}'."

        # execute the block
        block.call

        # remove the lock file
        locker.remove_lock
        Helper.log.info "[LOCKER] Unlocked execution context '#{locker.lock_name}' -> '#{locker.lock_file_name}'."

        locker
      end
    end
  end
end
