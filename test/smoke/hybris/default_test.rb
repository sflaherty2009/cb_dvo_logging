# # encoding: utf-8

# Inspec test for recipe cb_dvo_logging::hybrisWebServer

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'SumoLogic_sources.json' do
  impact 1.0
  title 'SumoLogic sources.json content check'
  desc 'Confirm that the sources.json file has been updated.'
  describe file('/opt/SumoCollector/config/sources.json') do
    it { should be_file }
  end
  describe file('/opt/SumoCollector/config/sources.json') do
    its('content') { should match 'Hybris' }
  end
  describe file('/opt/SumoCollector/config/sources.json') do
    its('content') { should_not match 'Apache' }
  end
  describe file('/opt/SumoCollector/config/sources.json') do
    its('content') { should_not match 'Linux' }
  end
  describe file('/opt/SumoCollector/config/sources.json') do
    its('content') { should_not match 'Docker' }
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
    describe file('/opt/sumologs') do
      it { should be_linked_to '/standard/sumologs' }
    end
    describe directory('/opt/sumologs/apache') do
      it { should_not be_directory }
    end
    describe directory('/opt/sumologs/hybris') do
      it { should be_directory }
    end
    describe directory('/opt/sumologs/solr') do
      it { should_not be_directory }
    end
  end
end
