# Plex-Scripts

Will eventually add all useful plex scripts I have created here.
***********************************************************************
**xml_wrapper.sh:**

This is the bash wrapper used to invoke xml_clean.ps1 using a service only, **not a cron job**. The script recurringly runs and checks for changes every 5 seconds, so do not run multiple instances of the script, just a systemd service is needed to call the xml_wrapper on system reboot.

Change the path to xml_clean.ps1 in this wrapper to wherever you will be storing these files.

**xml_clean.ps1:**

Used to clean up IPTV EPG files generated mainly from epg.best, though I assume it will work the same for other EPG providers that use the same guide APIs. 
This will create a config.json file in the /home/user/.xteve/data directory (create if it doesn't exist). It indexes all XML files for xTeve and their file hashes, then removes data from the xml files that will cause freezing in Plex for these EPGs, and then call the Plex API to reload the EPG guide.

You need to update the script with your Plex Token and the DVR key of the xTeve DVR, these can be seen when viewing XMLs in your plex library.

Requirements: 

If on Linux, look for instructions on how to install PowerShell Core.
