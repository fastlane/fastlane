describe Fastlane::Helper::S3ClientHelper do
  subject { described_class.new }

  describe '#find_bucket!' do
    before { class_double('Aws::S3::Bucket', new: bucket).as_stubbed_const }

    context 'when bucket found' do
      let(:bucket) { instance_double('Aws::S3::Bucket', exists?: true) }

      it 'returns bucket' do
        expect(subject.find_bucket!('foo')).to eq(bucket)
      end
    end

    context 'when bucket not found' do
      let(:bucket) { instance_double('Aws::S3::Bucket', exists?: false) }

      it 'raises error' do
        expect { subject.find_bucket!('foo') }.to raise_error("Bucket 'foo' not found")
      end
    end
  end

  describe '#delete_file' do
    it 'deletes s3 object' do
      object = instance_double('Aws::S3::Object', delete: true)
      bucket = instance_double('Aws::S3::Bucket', object: object)

      expect(subject).to receive(:find_bucket!).and_return(bucket)
      expect(object).to receive(:delete)
      subject.delete_file('foo', 'bar')
    end
  end
end
