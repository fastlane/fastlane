describe FastlaneCore::Secrets do
  describe '.mask' do
    it 'replaces a registered value' do
      described_class.register('tok-1234')

      expect(described_class.mask('token tok-1234 used')).to eq('token ******** used')
    end

    it 'replaces the escaped form sh prints for an environment hash' do
      described_class.register('p@ss word')

      expect(described_class.mask("PASSWORD=#{Shellwords.escape('p@ss word')} cmd")).to eq('PASSWORD=******** cmd')
    end

    it 'registers every string in a hash or an array' do
      described_class.register({ key_id: 'key-1234', nested: ['iss-5678'], duration: 1200 })

      expect(described_class.mask('key-1234 iss-5678')).to eq('******** ********')
    end

    it 'ignores values shorter than MIN_LENGTH' do
      described_class.register('abc')

      expect(described_class.mask('abc')).to eq('abc')
    end

    it 'masks a non-ASCII secret in invalid UTF-8 text without raising, keeping its encoding' do
      described_class.register('pässwörd-1')
      text = "\xFF pässwörd-1".dup.force_encoding(Encoding::UTF_8)

      masked = described_class.mask(text)

      expect(masked.b).to eq("\xFF ********".b)
      expect(masked.encoding).to eq(Encoding::UTF_8)
    end

    it 'leaves text alone when nothing is registered' do
      expect(described_class.mask('tok-1234')).to eq('tok-1234')
    end

    it 'leaves text alone when FASTLANE_DISABLE_SECRET_MASKING is set' do
      described_class.register('tok-1234')

      FastlaneSpec::Env.with_env_values('FASTLANE_DISABLE_SECRET_MASKING' => '1') do
        expect(described_class.mask('token tok-1234 used')).to eq('token tok-1234 used')
      end
    end
  end

  describe FastlaneCore::Secrets::OutputFilter do
    it 'masks what puts, print, abort-style writes and Logger send to the IO' do
      described_class # loaded
      FastlaneCore::Secrets.register('tok-1234')
      reader, writer = IO.pipe
      writer.singleton_class.prepend(described_class)

      writer.puts('puts tok-1234')
      writer.print("print tok-1234\n")
      writer << "shovel tok-1234\n"
      Logger.new(writer).info('logger tok-1234')
      writer.close

      expect(reader.read).not_to include('tok-1234')
    end

    it 'masks nothing when FASTLANE_DISABLE_SECRET_MASKING is set' do
      FastlaneCore::Secrets.register('tok-1234')
      reader, writer = IO.pipe
      writer.singleton_class.prepend(described_class)

      FastlaneSpec::Env.with_env_values('FASTLANE_DISABLE_SECRET_MASKING' => '1') do
        writer.puts('puts tok-1234')
        Logger.new(writer).info('logger tok-1234')
      end
      writer.close

      expect(reader.read.scan('tok-1234').size).to eq(2)
    end

    it 'is not installed on $stdout and $stderr when FASTLANE_DISABLE_SECRET_MASKING is set' do
      # Fresh streams: the real ones keep the filter an earlier example installed
      stdout = $stdout
      stderr = $stderr
      $stdout = StringIO.new
      $stderr = StringIO.new
      begin
        FastlaneSpec::Env.with_env_values('FASTLANE_DISABLE_SECRET_MASKING' => '1') do
          FastlaneCore::Secrets.register('tok-1234')
        end

        expect($stdout.singleton_class).not_to include(described_class)
        expect($stderr.singleton_class).not_to include(described_class)
      ensure
        $stdout = stdout
        $stderr = stderr
      end
    end

    it 'is installed on $stdout and $stderr when a secret is registered' do
      FastlaneCore::Secrets.register('tok-1234')

      expect($stdout.singleton_class).to include(described_class)
      expect($stderr.singleton_class).to include(described_class)
    end
  end
end
