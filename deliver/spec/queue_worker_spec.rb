require 'deliver/queue_worker'

describe Deliver::QueueWorker do
  describe '#enqueue' do
    subject { described_class.new(1) { |_| } }

    it 'should accepet any object' do
      expect { subject.enqueue(1) }.not_to(raise_error)
      expect { subject.enqueue('aaa') }.not_to(raise_error)
      expect { subject.enqueue([1, 2, 3]) }.not_to(raise_error)
      expect { subject.enqueue(Object.new) }.not_to(raise_error)
    end
  end

  describe '#batch_enqueue' do
    subject { described_class.new(1) { |_| } }

    it 'should take an array as multiple jobs' do
      expect { subject.batch_enqueue([1, 2, 3]) }.not_to(raise_error)
      expect { subject.batch_enqueue(1) }.to(raise_error(ArgumentError))
    end
  end

  describe '#start' do
    it 'should dispatch enqueued items to given block in FIFO order' do
      dispatched_jobs = []

      subject = described_class.new(1) do |job|
        dispatched_jobs << job
      end

      subject.enqueue(1)
      subject.enqueue('aaa')
      subject.start

      expect(dispatched_jobs).to eq([1, 'aaa'])
    end

    it 'should not be reused once it\'s started' do
      subject = described_class.new(1) { |_| }

      subject.enqueue(1)
      subject.start

      expect { subject.enqueue(2) }.to raise_error(ClosedQueueError)
    end
  end
end
