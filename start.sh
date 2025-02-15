# start.sh
#!/bin/bash

# Download bore (modern TCP tunnel)
curl -sL https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-apple-darwin.tar.gz | tar xz
chmod +x bore
sudo mv bore /usr/local/bin/

# System configuration
sudo mdutil -i off -a
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName Runner_Admin
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/tcv
sudo dscl . -passwd /Users/runneradmin P@ssw0rd!
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin

# VNC Configuration
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes 

echo runnerrdp | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Restart services
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate

# Start bore tunnel in background
bore local 5900 > bore.log 2>&1 &

# Get public URL after tunnel establishes
sleep 10
BORE_URL=$(grep 'Listening on' bore.log | awk '{print $3}')
echo "BORE_URL=$BORE_URL" >> $GITHUB_ENV
