require 'shellwords'
require 'credentials_manager'

describe FastlaneCore do
  describe FastlaneCore::ItunesTransporter do
    def shell_upload_command(provider_short_name = nil)
      [
        '"' + FastlaneCore::Helper.transporter_path + '"',
        "-m upload",
        '-u "fabric.devtools@gmail.com"',
        "-p '\\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<'",
        "-f '/tmp/my.app.id.itmsp'",
        "-t 'Signiant'",
        "-k 100000",
        ("-itc_provider #{provider_short_name}" if provider_short_name)
      ].compact.join(' ')
    end

    def shell_download_command(provider_short_name = nil)
      [
        '"' + FastlaneCore::Helper.transporter_path + '"',
        '-m lookupMetadata',
        '-u "fabric.devtools@gmail.com"',
        "-p '\\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<'",
        "-apple_id my.app.id",
        "-destination '/tmp'",
        ("-itc_provider #{provider_short_name}" if provider_short_name)
      ].compact.join(' ')
    end

    def java_upload_command(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-classpath #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        'com.apple.transporter.Application',
        "-m upload",
        "-u fabric.devtools@gmail.com",
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        "-f /tmp/my.app.id.itmsp",
        "-t Signiant",
        "-k 100000",
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    def java_download_command(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-classpath #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        'com.apple.transporter.Application',
        '-m lookupMetadata',
        '-u fabric.devtools@gmail.com',
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        '-apple_id my.app.id',
        '-destination /tmp',
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    describe "with Xcode 7.x installed" do
      before(:each) { allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('7.3') }

      describe "by default" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command)
          end
        end
      end

      describe "use_shell_script is false with a itc_provider short name set" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false, 'abcd1234')
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command('abcd1234'))
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false, 'abcd1234')
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command('abcd1234'))
          end
        end
      end

      describe "use_shell_script is true with a itc_provider short name set" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true, 'abcd1234')
            expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command('abcd1234'))
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true, 'abcd1234')
            expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command('abcd1234'))
          end
        end
      end

      describe "when use shell script ENV var is set" do
        describe "upload command generation" do
          it 'generates a call to the shell script' do
            with_env_values('FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT' => 'true') do
              transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
              expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
            end
          end
        end

        describe "download command generation" do
          it 'generates a call to the shell script' do
            with_env_values('FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT' => 'true') do
              transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
              expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
            end
          end
        end
      end

      describe "use_shell_script is true" do
        describe "upload command generation" do
          it 'generates a call to the shell script' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true)
            expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to the shell script' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true)
            expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
          end
        end
      end

      describe "use_shell_script is false" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command)
          end
        end
      end
    end

    describe "with Xcode 6.x installed" do
      before(:each) { allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('6.4') }

      describe "upload command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
        end
      end

      describe "download command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
        end
      end
    end
  end
end
