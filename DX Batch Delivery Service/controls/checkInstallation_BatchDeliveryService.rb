# encoding: utf-8
# copyright: 2018, Adrian Finnegan

version = attribute('version', default: '0.1111.1', description: 'Expected version of application')

control 'batchDeliverServiceInstallationVerify' do
	impact 1.0
	title 'Checks Batch Delivery Service installation'
	desc "Checks if components of Batch Delivery Service have been installed"

	###############################
	# Known dependency compliance
	################################
	
	# Version of .Net
	# 
	# 
	
	####################################
	# Clinical Data Service compliance
	####################################
	
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\App_Data') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\bin') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\conf') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\Resources') do
		it { should exist }
		it { should be_directory }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\Global.asax') do
		it { should exist }
		it { should be_file }
	end
	
	describe file('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService\Web.config') do
		it { should exist }
		it { should be_file }
	end
	
	describe registry_key({
	name: 'Clinical Data Service', 
	hive: 'HKEY_LOCAL_MACHINE',
	key: '\SOFTWARE\Wow6432Node\Navimedix\InstalledPackages\ClinicalDataService\Dynamic\\'+version
	}) do
		its('InstallStatus') { should eq 'Success' }
		its('Version') { should match version }
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
	
	describe iis_app('/v1/dx-batch-delivery', 'DYNAMIC') do
		it { should exist }
		it { should have_physical_path('D:\NaviNet\Api\v1\DocumentExchangeBatchDeliveryService') }
		it { should have_application_pool('DocumentExchangeBatchDeliveryAppPool') }
		it { should have_protocol('http') }

	end
	
	
end