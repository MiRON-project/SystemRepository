#!/bin/bash
#--------------------------------------------------------------------------
# Code generated by the SmartSoft MDSD Toolchain
# The SmartSoft Toolchain has been developed by:
#  
# Service Robotics Research Center
# University of Applied Sciences Ulm
# Prittwitzstr. 10
# 89075 Ulm (Germany)
#
# Information about the SmartSoft MDSD Toolchain is available at:
# www.servicerobotik-ulm.de
#
# Please do not modify this file. It will be re-generated
# running the code generator.
#--------------------------------------------------------------------------
#
# run this script from the component's root folder to deploy the scenario to robot.
#

echo "Working directory of deployment script: "`pwd`

BASENAME=`pwd | xargs basename`
if [ "$BASENAME" != "smartsoft" ]; then
	echo "Folder: $BASENAME vs Model: smartsoft did not match"
	echo "###################################################################"
	echo "ERROR: this script must be called from the project's smartsoft folder."
	echo "###################################################################"
	gdialog --title ERROR --msgbox "ERROR: this script must be called from the component's root folder."
	exit 1
fi

#gdialog --title "Deployment" --yesno "Deploy scenario to remote host?"
#if [ "$?" != "0" ]; then
#	DEPL_MODE="local"
#fi

echo "combine ini-files"
bash src-gen/deployment/combine_ini_files.sh

DEVICES="
PC1
"

exec 99> >(zenity --progress --auto-close --pulsate --no-cancel --width 300)

for I in $DEVICES; do
	echo "#Deploying Device $I ..." >&99
	#gdialog --title "Deployment" --yesno "Device $I is about to be deployed.\nContinue?" || continue
	
	bash src-gen/deployment/deploy-$I.sh ${DEPL_MODE}
	if [ "$?" != "0" ]; then
		zenity --error --text="Deployment to $I failed.\nAborting Deployment."
		exit 1
	fi
done

exec 99>&-

gdialog --title "Deployment" --yesno "Deployment finished. Do you want to start it now?"
if [ "$?" != "0" ]; then
	echo
	echo "Scenario not started."
	echo "Execute the startscript 'start-<DEVICENAME>.sh' on the remote device in order to execute the scenario."
	echo
	exit 0
fi

if [ "$DEPL_MODE" = "local" ]; then
	for I in $DEVICES; do
		cd SystemLaserObstacleAvoidTiagoGazeboSimulator.deployment/$I
		xterm -title "Scenario Control of Device $I" -e "pwd;bash start-$I.sh menu;echo;echo;echo;echo 'You can close this window now.'; echo; echo;bash --login"
	done
else
	#gdialog --title "Deployment" --yesno "remote start not yet implemented!!!!!!!!!!!!!!!!!!"
	xterm -title "Global Scenario Control" -e "cd src-gen/deployment; pwd; bash start-all.sh menu;echo;echo;echo;echo 'You can close this window now.'; echo; echo;bash --login"
fi

echo -e "\n\nDeployment finished.\n\n"
exit 0
