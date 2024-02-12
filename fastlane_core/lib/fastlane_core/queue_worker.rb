require 'thread'

module FastlaneCore
  # This dispatches jobs to worker threads and make it work in parallel.
  # It's suitable for I/O bounds works and not for CPU bounds works.
  # Use this when you have all the items that you'll process in advance.
  # Simply enqueue them to this and call `QueueWorker#start`.
  class QueueWorker
    NUMBER_OF_THREADS = FastlaneCore::Helper.test? ? 1 : [ENV["DELIVER_NUMBER_OF_THREADS"], ENV["FL_NUMBER_OF_THREADS"], 10].map(&:to_i).find(&:positive?).clamp(1, ENV.fetch("FL_MAX_NUMBER_OF_THREADS", 10).to_i)

    # @param concurrency (Numeric) - A number of threads to be created
    # @param block (Proc) - A task you want to execute with enqueued items
    def initialize(concurrency = NUMBER_OF_THREADS, &block)
      @concurrency = concurrency
      @block = block
      @queue = Queue.new
    end

    # @param job (Object) - An arbitrary object that keeps parameters
    def enqueue(job)
      @queue.push(job)
    end

    # @param jobs (Array<Object>) - An array of arbitrary object that keeps parameters
    def batch_enqueue(jobs)
      raise(ArgumentError, "Enqueue Array instead of #{jobs.class}") unless jobs.kind_of?(Array)
      jobs.each { |job| enqueue(job) }
    end

    # Call this after you enqueued all the jobs you want to process
    # This method blocks current thread until all the enqueued jobs are processed
    def start
      @queue.close

      threads = []
      @concurrency.times do
        threads << Thread.new do
          job = @queue.pop
          while job
            @block.call(job)
            job = @queue.pop
          end
        end
      end

      threads.each(&:join)
    end
  end
end
