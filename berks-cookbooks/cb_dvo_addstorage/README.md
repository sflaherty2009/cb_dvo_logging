# cb_dvo_addStorage

This Cookbook adds all drives attached to a VM _**at provisioning time**_.  

It will not add drives added after initial provisioning as it is guarded by the existance of the platform-specific mount points (see default.rb).  The cookbook assumes anything that is of size 979 is a standard storage device.  Premium storage devices must be one of the standard sizes (32, 64, 128, 512, 1024, 2048 or 4095 GB).  This is controlled by the orchestrator.

Upon successfully attaching storage this cookbook (as of version 2.0.4) sets the attributes ['dvo']['storage']['standard_available'] and ['dvo']['storage']['premium_available'] to the boolean value true or false based on their existance. This happens at converge time by necessity, so these must be accessed lazily or within a block that is evaluated at converge time as well. Additionally (as of version 2.0.5), all logic for handling storage attributes is handled here as well. Any attribute defined ending with ['storage_class'] = 'value' will be checked, verified, and set to normal values to persist or raise an exception in very specific cases where the requested storage is not available and there is no logical fallback option. Finally, a ['windows_drive'] attribute will be created at the same path as ['storage_class'] to designate the drive letter of the windows disk to be used.

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
