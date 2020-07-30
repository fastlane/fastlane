require 'thread'

module Deliver
  # This dispatches jobs to worker threads and make it work in parallel.
  # It's suitable for I/O bounds works and not for CPU bounds works.
  # Use this when you have all the items that you'll process in advance.
  # Simply enqueue them to this and call `QueueWorker#start`.
  class QueueWorker
    # @param concurrency (Numeric) - A number of threads to be created
    # @param block (Proc) - A task you want to execute with enqueued items
    def initialize(concurrency, &block)
      @concurrency = concurrency
      @block = block
      @queue = Queue.new
    end

    # @param job (Object) - An arbitary object that keeps parameters
    def enqueue(job)
      @queue.push(job)
    end

    # Call this after you enqueuned all the jobs you want to process
    # This method blocks current thread until all the enqueued jobs are processed
    def start
      threads = []
      @concurrency.times do
        threads << Thread.new do
          while running? && !empty?
            job = @queue.pop
            @block.call(job) if job
          end
        end
      end

      wait_for_complete
      threads.each(&:join)
    end

    private

    def running?
      !@queue.closed?
    end

    def empty?
      @queue.empty?
    end

    def wait_for_complete
      wait_thread = Thread.new do
        loop do
          if @queue.empty?
            @queue.close
            break
          end

          sleep(1)
        end
      end

      wait_thread.join
    end
  end
end
