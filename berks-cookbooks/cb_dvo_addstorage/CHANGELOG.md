# 2.0.1
## Date: 11/10/2017

Update to make new devices writable by all who have account-level access to that VM.

# 2.0.0
## Date: 11/10/2017

Major rewrite to accomodate multiple data disks of various performance tiers.
* On Windows, all premium devices are combined into a Windows Storage Space at P:\ and all standard devices are combined at S:\
* On Linux, premium is at /premium and standard is at /standard
* This only adds drives available at provisioning time; the cookbook is guarded by the existance of the mount points in both Windows and Linux (see default.rb)

# 0.1.3
## Date 9/2/2017

* Found out that we couldn't map Docker images to this FS because it ran out of inodes using the largefile4 inode and inode ratio defaults set in /etc/mke2fs.conf
* Increased inodes to 268 million, but know that this consumes 64 GB of space to address all of those inodes
* This change will not be made to an existing system until the partition is deleted using fdisk...  so bad thing is that it won't fix the problem automagically... but the good thing is it won't delete the partition to fix the problem.
* Had to increment from 0.1.2 to 0.1.3 because there was already a 0.1.2 on the Chef Sever (??)

# 0.1.1
## Date 6/16/2017

* Included support for Windows Server 2016 Datacenter

# 0.1.0
## Date: 6/12/2017

* Development release
* Removed file resource block and delete notifier from linux recipe; will cause it to converge 1 resource every time assuming the addDrives.bash file is present in /root/.
