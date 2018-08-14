# How to install Android SDK for MAC
Download from Oracle: 
[JRE](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html)
[JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)


# How to remove Android from MAC:

Run this command to just remove the JDK

```
sudo rm -rf /Library/Java/JavaVirtualMachines/jdk<version>.jdk
```

Run these commands if you want to remove plugins

```
sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane
sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
sudo rm -rf /Library/LaunchAgents/com.oracle.java.Java-Updater.plist
sudo rm -rf /Library/PrivilegedHelperTools/com.oracle.java.JavaUpdateHelper
sudo rm -rf /Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist
sudo rm -rf /Library/Preferences/com.oracle.java.Helper-Tool.plist
```
