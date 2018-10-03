# encoding: utf-8
# copyright: 2018, Adrian Finnegan

control 'documentExchangeInstallatonVerify' do
	impact 1.0
	title 'Checks CDS installation'
	desc "Checks components of Clinical Data Servic have been successfully installed"

	###############################
	# Known dependency compliance
	################################
	
	# Version of .Net
	# 
	# 
	
	####################################
	# Clinical Data Service compliance
	####################################
	
	describe file('D:\NaviNet\ClinicalGateway') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\ClinicalGateway\bin') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\ClinicalGateway\conf') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\ClinicalGateway\resources') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\ClinicalGateway\Global.asax') do
		it { should exist }
		it { should be_file }
	end
	
	describe file('D:\NaviNet\ClinicalGateway\web.config') do
		it { should exist }
		it { should be_file }
	end
	
	describe registry_key({
	name: 'Clinical Data Service', 
	hive: 'HKEY_LOCAL_MACHINE',
	key: '\SOFTWARE\Wow6432Node\Navimedix\InstalledPackages\ClinicalDataService\Dynamic\0.1477.1'
	}) do
		its('InstallStatus') { should eq 'Success' }
		its('Version') { should match /^0.1477.[0-9].[0-9]*$/ }
	end
	
	describe service('W3SVC') do
	  it { should be_installed }
	  it { should be_running }
	end

	describe iis_site('DYNAMIC') do
		it { should exist }
		it {should be_running }
		it { should have_binding('http *:80:') }
		
		
	end
	
	describe iis_app('/document-exchange', 'DYNAMIC') do
		it { should exist }
		it { should have_physical_path('D:\NaviNet\ClinicalGateway') }
		it { should have_application_pool('ClinicalGatewayAppPool') }
		it { should have_protocol('http') }

	end
	
	
end