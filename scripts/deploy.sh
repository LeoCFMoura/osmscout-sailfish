#!/bin/bash
# http://nckweb.com.ar/sailing-code/2015/01/01/develop-without-qtcreator/

if [ $# -lt 1 ] ; then
	echo "Too few arguments!"
	echo "Usage:"
	echo "  $0 build-type"
	echo 
	echo "build type can be emulator or phone"
	
	exit 1
fi

export TYPE="$1" # emulator
export PROJECT_NAME="osmscout-sailfish" 


PROJECT_TARGET="$PROJECT_NAME"

##################################################################
## project root
export MER_SSH_SHARED_SRC="$HOME/SailfishOS/projects/"
## SDK ROOT
export SDK_ROOT="$HOME/SailfishOS/"

## build & deploy target
## list of configured devices: ~/SailfishOS/vmshare/devices.xml 
if [ "$TYPE" = "emulator" ] ; then
	export MER_SSH_DEVICE_NAME="SailfishOS Emulator"
	# 	ssh nemo@localhost -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo
	export DEV_SSH_USER=nemo
	export DEV_SSH_HOST=localhost
	export DEV_SSH_PORT=2223
	export MER_SSH_TARGET_NAME=SailfishOS-i486
	export DEV_SSH_KEY="$SDK_ROOT/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo"
	
	## emulator vm
	if [ `VBoxManage list runningvms | grep -c "$MER_SSH_DEVICE_NAME"` -eq 0 ] ; then
		echo "Starting emulator"
# 		VBoxSDL -startvm "$MER_SSH_DEVICE_NAME" & 
		VBoxManage startvm "$MER_SSH_DEVICE_NAME"  
# 		VBoxManage controlvm "SailfishOS Emulator" poweroff
		sleep 3
	else
		echo "Emulator is running already"
	fi	
else
	export MER_SSH_DEVICE_NAME="Jolla (ARM)"
	export DEV_SSH_USER=nemo
	export DEV_SSH_HOST=192.168.2.15
	export DEV_SSH_PORT=22
	export MER_SSH_TARGET_NAME=SailfishOS-armv7hl
	export DEV_SSH_KEY="$SDK_ROOT/vmshare/ssh/private_keys/Jolla_(ARM)/nemo"
fi



##################################################################
export MER_SSH_PROJECT_PATH="$MER_SSH_SHARED_SRC/$PROJECT_NAME"
export PROJECT_FILE="$MER_SSH_PROJECT_PATH/$PROJECT_TARGET.pro"

export PROJECT_BUILD_DIR="$MER_SSH_PROJECT_PATH/build-$MER_SSH_TARGET_NAME"
export MER_SSH_SDK_TOOLS="$HOME/.config/SailfishBeta7/mer-sdk-tools/MerSDK/$MER_SSH_TARGET_NAME"

export MER_SSH_SHARED_HOME="$HOME"
export MER_SSH_SHARED_TARGET="$SDK_ROOT/mersdk/targets/"
export SDK_VM_NAME=MerSDK

## SDK ssh config
export MER_SSH_CMD="$SDK_ROOT/bin/merssh"
export MER_SSH_PRIVATE_KEY="$SDK_ROOT/vmshare/ssh/private_keys/engine/mersdk"
export MER_SSH_USERNAME=mersdk
export MER_SSH_PORT=2222
export SDK_SSH_HOST=localhost

##################################################################
## SDK vm
if [ `VBoxManage list runningvms | grep -c "$SDK_VM_NAME"` -eq 0 ] ; then
	echo "Starting SDK..."
	VBoxHeadless -startvm "$SDK_VM_NAME" &
	#VBoxSDL -startvm "$SDK_VM_NAME" &
# 	VBoxManage controlvm "$SDK_VM_NAME" poweroff
	sleep 3
else
	echo "SDK is running already"
fi

function sdk_cmd {
 echo "$@" | ssh \
    -q \
    -p $MER_SSH_PORT \
    -i "$MER_SSH_PRIVATE_KEY" \
    "$MER_SSH_USERNAME@$SDK_SSH_HOST"
}

##################################################################
## 
echo
echo "build rpm..."

sdk_cmd "cd /home/mersdk/share/SailfishOS/projects/$PROJECT_NAME/ && mb2 -t SailfishOS-armv7hl build"
  
##################################################################
## 
echo
echo "deploy..."

"$MER_SSH_CMD" \
  deploy --sdk
  
echo 
echo "run"
# "$MER_SSH_CMD" \
#   ssh "/usr/bin/$PROJECT_NAME"
# cat "$SDK_ROOT/vmshare/devices.xml"
ssh $DEV_SSH_USER@$DEV_SSH_HOST \
  -i "$DEV_SSH_KEY" \
  -p "$DEV_SSH_PORT" \
  "/usr/bin/$PROJECT_TARGET"



