# Server Compliance Scripts

## Background

InSpec is a an auditing tool we can use to audit our applications and infrastructure - verifying that the application Team City deployed, is actually the application we requested. 
This POC demonstrates controls for Document Exchange and its peripheral applications.

More information on InSpec can be found here: https://www/inspec.io

## Installation

This suite relies on installation of InSpec. The latest version can be found here: https://www.InSpec.io

## Execution

1. Download all of the files from the src directory
2. Open a command prompt and execute 
	`> inspec check`
	(./images/Initial_Check.png)
3. `> inspec exec .`

## Auditing covered

1. Clinical Data Service
2. Document Exchange Batch Delivery Service