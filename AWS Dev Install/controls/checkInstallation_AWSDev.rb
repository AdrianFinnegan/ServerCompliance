# encoding: utf-8
# copyright: 2018, Adrian Finnegan

default_dev_install = attribute('default_dev_install', default: 'XX:\Dev\\', description: 'Location of development environment code')
default_core_install = attribute('default_core_install', default: 'C:\Dev\\', description: 'Root location of core applications e.g. CMS UI, Portal UI etc')
federation_resources_location = attribute('federation_resources_location', default: 'C:\NaviMedix\FedResources\\', description: 'Federation Resources folder')

control 'awsDevVMInstallationVerify' do
	impact 1.0
	title 'Check AWS VM installation'
	desc "Checks if all components of the AWS installation have completed"

	###############################
	# Platform Checks
	################################
	
	# Visual Studio 2010, 2015, 2017
	# Cygwin
	# Version of .Net 1, 2 4
	# IIS active
	# NantHealth in Host file
	# Home Directory changed to <user> from DHaldankar
	# Build Action command missing (see troubleshooting)**
	# Federation Resource databaase value
	# Update Registry values for dev-db-02 database
	# MVC 4 installed
	# Time Zone should be Eastern Time Zone (see Troubleshooting)
	# AL.exe Toolpath (see Troubleshooting)
	# Allow anonymous authentication on IIS site (see Troubleshooting)

	describe registry_key({
	name: 'Visual Studio', 
	hive: 'HKEY_LOCAL_MACHINE',
	key: '\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7'
	}) do
		it('10.0') { should exist } # Visual Studio 2010
		it('14.0') { should exist } # Visual Studio 2015
		it('15.0') { should exist } # Visual Studio 2017
		
	end
	
	####################################
	# NaviNet Components
	#####################################

	
	describe service('W3SVC') do
	  it { should be_installed }
	  it { should be_running }
	end

	# describe iis_site('Default_Web_Site') do
		# it { should exist }
		# # it { should be_running }
		# # it { should have_binding('http *:80:') }
		
		
	# end
	
	## Auths UI
	# describe iis_app('login', 'default web site') do
		# it { should exist }
		# it { should have_protocol('http') }
		# it { should have_physical_path(default_core_install + 'NaviNetAuthenticationUI\Development\Code\Dynamic') }
	# end
	
	authsAnonymousAuthEnabledScript = <<-EOH
		$response = Get-WebConfigurationProperty -filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites\\Default Web Site\\login" -name enabled.value
		Write-Output $response.ToString()
	EOH
	describe powershell(authsAnonymousAuthEnabledScript) do
		# its('stdout') { should_not eq '' }
		its('exit_status') { should eq 0 }
		its('stderr') { should eq "" }
		its('strip') { should match (/.*True.*/) }
	end
	
	
	
	## CMS Content UI
	describe iis_app('cms-content-ui', 'default web site') do
		it { should exist }
		it { should have_protocol('http') }
		it { should have_physical_path(default_core_install + 'CmsContentUI\src\CmsContentUI.Web') }
	end
	
	## Portal UI
	describe iis_app('plan-management-service-mock', 'default web site') do
		it { should exist }
		it { should have_protocol('http') }
		it { should have_physical_path(default_core_install + 'CmsContentUI\src\PlanManagementServiceMock') }
	end
	describe iis_app('portal-layout-ui-mock', 'default web site') do
		it { should exist }
		it { should have_application_pool('PortalLayoutUIMock') }
		it { should have_protocol('http') }
		it { should have_physical_path(default_core_install + 'PortalLayoutUI\tests\PortalLayoutUI.MockContentApp') }
	end
	
	describe iis_app('portal-shared', 'default web site') do
		it { should exist }
		it { should have_protocol('http') }
		it { should have_physical_path(federation_resources_location + 'Client\NaviMedix\NaviNet\Portal\MasterPages\Static') }
	end
	
	describe iis_app('portal-ui-service', 'default web site') do
		it { should exist }
		it { should have_protocol('http') }
		it { should have_physical_path(default_core_install + 'PortalUIService\src\PortalUIService') }
	end
	
	describe iis_app('portal-ui-service-mock', 'default web site') do
		it { should exist }
		it { should have_application_pool('PortalUIServiceMock') }
		it { should have_protocol('http') }
		it { should have_physical_path(default_core_install + 'PortalUIService\tests\PortalUIService.MockContentApp') }
	end
	
	describe file('C:\cygwin') do
	  it { should exist }
	  it { should be_directory }
	end
	describe registry_key('Cygwin', 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Cygwin\setup') do
		it('rootdir') { should exist } 
	end
	
	##.Net Framework installation
	describe registry_key('.Net Version 1', 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v1.1.4322') do
		it('(Default)') { should exist } 
	end
	describe registry_key('.Net Version 2', 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v2.0.50727') do
		it('(Default)') { should exist } 
	end
	describe registry_key('.Net Version 4', 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4') do
		it('(Default)') { should exist } 
	end
	
	## AL.exe Toolpath
	describe file('C:\Windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.Common.targets') do
	    it { should exist }
	    it { should be_file }
		its('content') { should_not match 'ToolPath="$(AlToolPath)"'}
	end
	
	## NantHealth Hostfile
	describe file('C:\Windows\System32\drivers\etc\hosts') do
	  it { should exist }
	  it { should be_file }
	  its('content') { should match  '10.80.25.21'}
	  its('content') { should match  'git.nanthealth.com'}
	end
	
	## Home Variable
	describe os_env('HOME') do
		its('content') { should_not eq nil }
		its('content') { should_not include('DHaldankar') }
	end
	
	## Federation Resources
	describe registry_key('Dev DB O2', 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NaviMedix\NaviNet\RPA DB') do
		it('Server') { should_not eq nil } 
		it('Server') { should_not eq ('dev-db-02') } 
	end
	describe registry_key('Dev DB O2', 'HKEY_LOCAL_MACHINE\SOFTWARE\NaviMedix\NaviNet\RPA DB') do
		it('Server') { should_not eq nil } 
		it('Server') { should_not eq ('dev-db-02') } 
	end
	
	describe file(federation_resources_location + 'Server\NaviMedix\FederationRuntime\EnvFederationRuntime.bat') do
		it { should exist }
		its('content') { should_not match (/.*dev-db-02.*/) }
	end
	describe file(federation_resources_location + 'Server\Navimedix\FederationRuntime\profile-database-registry.xml') do
		it { should exist }
		its('content') { should_not match (/.*dev-db-02.*/) }
	end
	describe file(default_core_install + 'PortalUIService\src\PortalUIService\web.config') do
		it { should exist }
		it { should be_file }
		its('content') { should_not match (/.*dev-db-02.*/) }
	end
	
	## MVC 4
	describe file('C:\Program Files (x86)\Microsoft ASP.NET\ASP.NET MVC 4') do
		it { should exist }
		it { should be_directory }
	end
	
	## Time Zone
	timeZoneScript = <<-EOH
		[System.TimeZone]::CurrentTimeZone
	EOH
	describe powershell(timeZoneScript) do
		its('stdout') { should_not eq '' }
		its('exit_status') { should eq 0 }
		its('stderr') { should eq "" }
		its('stdout') { should match (/.*Eastern Standard Time.*/) }
	end
	
	
end