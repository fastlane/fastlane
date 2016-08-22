require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Installer do
    def fixture(date)
      File.read("spec/fixtures/devcenter/xcode-#{date}.html")
    end

    def parse_prereleases(date)
      fixture = fixture(date)
      @result.stubs(:body).returns(fixture)

      installer = Installer.new
      installer.send(:prereleases)
    end

    before do
      devcenter = mock
      devcenter.stubs(:download_file).returns(nil)
      Installer.any_instance.stubs(:devcenter).returns(devcenter)

      @result = mock
      @result.stubs(:body).returns(nil)
      client = mock
      client.stubs(:request).returns(@result)
      Spaceship::PortalClient.stubs(:login).returns(client)
    end

    it 'can parse prereleases from 20150414' do
      prereleases = parse_prereleases('20150414')

      prereleases.should == [Xcode.new_prerelease('6.4', '/Developer_Tools/Xcode_6.4_Beta/Xcode_6.4_beta.dmg', '/Developer_Tools/Xcode_6.4_Beta/Xcode_6.4_beta_Release_Notes.pdf')]
    end

    it 'can parse prereleases from 20150427' do
      prereleases = parse_prereleases('20150427')

      prereleases.should == [Xcode.new_prerelease('6.4 beta 2', '/Developer_Tools/Xcode_6.4_beta_2/Xcode_6.4_beta_2.dmg', '/Developer_Tools/Xcode_6.4_beta_2/Xcode_6.4_beta_2_Release_Notes.pdf')]
    end

    it 'can parse prereleases from 20150508' do
      prereleases = parse_prereleases('20150508')

      prereleases.count.should == 2
      prereleases.first.should == Xcode.new_prerelease('6.3.2 GM seed', '/Developer_Tools/Xcode_6.3.2_GM_seed/Xcode_6.3.2_GM_seed.dmg', '/Developer_Tools/Xcode_6.3.2_GM_seed/Xcode_6.3.2_GM_Seed_Release_Notes.pdf')
      prereleases.last.should == Xcode.new_prerelease('6.4 beta 2', '/Developer_Tools/Xcode_6.4_beta_2/Xcode_6.4_beta_2.dmg', '/Developer_Tools/Xcode_6.4_beta_2/Xcode_6.4_beta_2_Release_Notes.pdf')
    end

    it 'can parse prereleases from 20150608' do
      prereleases = parse_prereleases('20150608')

      prereleases.count.should == 2
      prereleases.first.should == Xcode.new_prerelease('7 beta', '/WWDC_2015/Xcode_7_beta/Xcode_7_beta.dmg', '/WWDC_2015/Xcode_7_beta/Xcode_7_beta_Release_Notes.pdf')
      prereleases.last.should == Xcode.new_prerelease('6.4 beta 3', '/Developer_Tools/Xcode_6.4_beta_3/Xcode_6.4_beta_3.dmg', '/Developer_Tools/Xcode_6.4_beta_3/Xcode_6.4_beta_3_Release_Notes.pdf')
    end

    it 'can parse prereleases from 20150624' do
      prereleases = parse_prereleases('20150624')

      prereleases.count.should == 2
      prereleases.first.should == Xcode.new_prerelease('7 beta 2', '/Developer_Tools/Xcode_7_beta_2/Xcode_7_beta_2.dmg', '/Developer_Tools/Xcode_7_beta_2/Xcode_7_beta_2_Release_Notes.pdf')
      prereleases.last.should == Xcode.new_prerelease('6.4 beta 4', '/WWDC_2015/Xcode_6.4_beta_4/Xcode_6.4_beta_4.dmg', '/WWDC_2015/Xcode_6.4_beta_4/Xcode_6.4_beta_4_Release_Notes.pdf')
    end

    it 'can parse prereleases from 20150909' do
      prereleases = parse_prereleases('20150909')

      prereleases.count.should == 2
      prereleases.first.should == Xcode.new_prerelease('7.1 beta', '/Developer_Tools/Xcode_7.1_beta/Xcode_7.1_beta.dmg', '/Developer_Tools/Xcode_7.1_beta/Xcode_7.1_beta_Release_Notes.pdf')
      prereleases.last.should == Xcode.new_prerelease('7 GM seed', '/Developer_Tools/Xcode_7_GM_seed/Xcode_7_GM_seed.dmg', nil)
    end

    it 'can parse prereleases from 20160601' do
      prereleases = parse_prereleases('20160601')

      prereleases.count.should == 1
      prereleases.first.should == Xcode.new('8 beta', '/services-account/download?path=/WWDC_2016/Xcode_8_beta/Xcode_8_beta.xip', '/go/?id=xcode-8-beta-rn')
    end

    it 'can parse prereleases from 20160705' do
      prereleases = parse_prereleases('20160705')

      prereleases.count.should == 1
      prereleases.first.should == Xcode.new('8 beta 2', '/services-account/download?path=/Developer_Tools/Xcode_8_beta_2/Xcode_8_beta_2.xip', '/go/?id=xcode-8-beta-rn')
    end

    it 'can parse prereleases from 20160705 (alternative page)' do
      prereleases = parse_prereleases('20160705-alt')

      prereleases.count.should == 1
      prereleases.first.should == Xcode.new_prerelease('8 beta 2', '/devcenter/download.action?path=/Developer_Tools/Xcode_8_beta_2/Xcode_8_beta_2.xip', nil)
    end
  end
end
