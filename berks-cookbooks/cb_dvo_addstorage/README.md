# cb_dvo_addStorage

This Cookbook adds all drives attached to a VM _**at provisioning time**_.  

It will not add drives added after initial provisioning as it is guarded by the existance of the platform-specific mount points (see default.rb).  The cookbook assumes anything that is of size 979 is a standard storage device.  Premium storage devices must be one of the standard sizes (32, 64, 128, 512, 1024, 2048 or 4095 GB).  This is controlled by the orchestrator.

## How-To Linux & Windows

There is no how-to.  Simply add the devices to the resource.json for your VM and then provision.  The cookbook will take care of the rest.  

## Supported Platforms

** Officially supported platforms: **

* Windows Server 2012 R2 Datacenter
* Windows Server 2016 R2 Datacenter
* CentOS 7.4

** Other platforms *likely* to work: **
* NA

## Dependencies
None

## Platform-Specific Documentation

### Windows
* All drives added to class-specific Storage Spaces and Virtual Drives
* Premium at P:
* Standard at S:

### Linux
* All drives added to class-specific volume groups and logical volumes
* Premium at /premium
* Standard at /standard

## Usage

### cb_dvo_addStorage::default
* This cookbook is part of the base run list and will look for new drives to add every time the node converges

## Upgrade/Roll-back considerations

### Windows & Linux

This Cookbook has no anti-recipes at this point.  

## Proposed Enhancements
* Enable the post-provisioning addition of devices
* Set it up so that Vagrant builds the drives immediately for testing purposes
  * I worked quite a bit with the following, but couldn't get it or the kitchen-vagrant handler to work properly.  To get story through, I when ahead and did the drive adds to the VB VM, manually.
  * On this, refer to: https://github.com/test-kitchen/kitchen-vagrant#-virtualbox-additional-disk

## License and Authors

Author:: Ray Crawford (Ray_Crawford@trekbikes.com) -- Copyright 2017.
