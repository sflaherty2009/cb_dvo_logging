# # encoding: utf-8

# Inspec test for recipe cb_dvo_logging::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'SumoLogic_sources.json' do
  impact 1.0
  title 'SumoLogic sources.json content check'
  desc 'Confirm that the sources.json file has been updated.'
  unless os.windows?
    describe file('/opt/SumoCollector/config/sources.json') do
      it { should be_file }
    end
    describe file('/opt/SumoCollector/config/sources.json') do
      its('content') { should match 'Hybris' }
    end
    describe file('/opt/SumoCollector/config/sources.json') do
      its('content') { should match 'Apache' }
    end
    describe file('/opt/SumoCollector/config/sources.json') do
      its('content') { should match 'Linux' }
    end
    describe file('/opt/SumoCollector/config/sources.json') do
      its('content') { should match 'Docker' }
    end
  end
end

control 'SumoLogic_user.properties' do
  impact 1.0
  title 'SumoLogic user.properties content check'
  desc 'Confirm that the user.properties file has been updated with new keys'
  unless os.windows?
    describe file('/opt/SumoCollector/config/user.properties') do
      its('content') { should_not match '#accessid = [accessId]' }
    end
  end
end

control 'SumoLogic installation' do
  impact 1.0
  title 'SumoLogic installation confirmation'
  desc 'SumoLogic should be installed, enabled and started and links from log directory to ephemeral storage should be in place.'
  describe service('collector') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  unless os.windows?
    describe file('/opt/sumologs/apache') do
      it { should be_linked_to '/mnt/resource/sumologs/apache' }
    end
    describe file('/opt/sumologs/hybris') do
      it { should be_linked_to '/mnt/resource/sumologs/hybris' }
    end
  end
end
