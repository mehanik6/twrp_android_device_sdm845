#!/sbin/sh

LOG=/tmp/recovery.log
TAG=PREPDEC

F_LOG(){
   MSG="$1"
   echo -e "I:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}
F_ELOG(){
   MSG="$1"
   echo -e "E:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}
F_LOG "Started $0"

relink()
{
	fname=$(basename "$1")
	target="/sbin/$fname"
	sed 's|/system/bin/linker64|///////sbin/linker64|' "$1" > "$target"
	chmod 755 $target
}

# the dev path can be different so we need to identify it
syspathsoc="/dev/block/platform/soc/1d84000.ufshc/by-name/system"
syspathnosoc="/dev/block/platform/1d84000.ufshc/by-name/system"
syspath=undefined
while [ ! -e "$syspath" ];do
    [ -e "$syspathnosoc" ] && syspath="$syspathnosoc"
    [ -e "$syspathsoc" ] && syspath="$syspathsoc"
    F_LOG "syspath: $syspath"
    [ "$syspath" == "undefined" ] && F_LOG "sleeping a bit as syspath is not there yet.." && sleep 1
done

# prepare and mount
mkdir /s >> $LOG 2>&1 
mount -t ext4 -o ro "$syspath" /s  >> $LOG 2>&1 || F_ELOG "mounting /s to $syspath failed"

# directories
F_LOG "$(echo "Preparing directories:"; \
mkdir /vendor 2>&1 ; \ 
mkdir -p /system/etc 2>&1 ; \
mkdir -p /vendor/lib64/hw/ 2>&1 ; \
mkdir /persist-lg 2>&1 ; \ 
mkdir /firmware 2>&1)"

# this relinks (linker64) AND copies qseecomd to /sbin
if [ -f /s/vendor/bin/qseecomd ];then
    relink /s/vendor/bin/qseecomd  >> $LOG 2>&1
    [ $? -ne 0 ] && F_ELOG "relinking qseecomd failed (vendor)"
else
    relink /s/bin/qseecomd >> $LOG 2>&1 || F_ELOG "relinking qseecomd failed"
    [ $? -ne 0 ] && F_ELOG "relinking qseecomd failed (system)"
fi

F_LOG "preparing libraries..."

# copy the hws stuff
cp /s/bin/hwservicemanager /sbin/ >> $LOG 2>&1 
cp /s/lib64/libandroid_runtime.so /sbin/ >> $LOG 2>&1 
cp /s/lib64/libhidltransport.so /sbin/ >> $LOG 2>&1 
cp /s/lib64/libhidlbase.so /sbin/ >> $LOG 2>&1 
cp /s/lib64/android.hidl.base@1.0.so /sbin/ >> $LOG 2>&1 
cp /s/lib64/libicuuc.so /sbin/ >> $LOG 2>&1
cp /s/lib64/libxml2.so /sbin/ >> $LOG 2>&1

# copy the decrypt stuff
cp #/s/vendor/lib64/libdiag.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/lib64/libdrmfs.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/lib64/libdrmtime.so /sbin/ >> $LOG 2>&1 
cp #/s/vendor/lib64/libQSEEComAPI.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/lib64/librpmb.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/lib64/libssd.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/lib64/libtime_genoff.so /sbin/ >> $LOG 2>&1 
cp /s/vendor/manifest.xml >> $LOG 2>&1 
cp /s/vendor/compatibility_matrix.xml >> $LOG 2>&1 
cp /s/vendor/lib64/hw/android.hardware.keymaster@3.0-impl-qti.so /sbin/android.hardware.keymaster@3.0-impl-qti.so >> $LOG 2>&1 
cp /s/vendor/lib64/hw/android.hardware.gatekeeper@1.0-impl-qti.so /sbin/android.hardware.gatekeeper@1.0-impl-qti.so >> $LOG 2>&1 

cp /s/vendor/lib64/hw/android.hidl.base@1.0.so /sbin/android.hidl.base@1.0.so >> $LOG 2>&1 
#cp /s/vendor/lib64/hw/android.hardware.keymaster@3.0-impl-qti.so /vendor/lib64/hw/android.hardware.keymaster@3.0-impl-qti.so >> $LOG 2>&1 
#cp /s/vendor/lib64/libmdtp.so /vendor/lib64/libmdtp.so >> $LOG 2>&1 
cp /s/vendor/lib64/libqmi_common_so.so >> $LOG 2>&1 
cp /s/vendor/lib64/libsmemlog.so >> $LOG 2>&1 
cp /s/vendor/lib64/libqmiservices.so >> $LOG 2>&1 
cp /s/vendor/lib64/libqmi_encdec.so >> $LOG 2>&1 
cp /s/vendor/lib64/libqmi_client_qmux.so >> $LOG 2>&1 
cp /s/vendor/lib64/libqmi_cci.so >> $LOG 2>&1 
cp /s/vendor/lib64/libmdmdetect.so >> $LOG 2>&1 
cp /s/vendor/lib64/libidl.so >> $LOG 2>&1 
cp /s/vendor/lib64/libdsutils.so >> $LOG 2>&1 
cp /s/vendor/lib64/libdiag.so >> $LOG 2>&1 
cp /s/vendor/lib64/libQSEEComAPI.so >> $LOG 2>&1 
cp /s/vendor/lib64/libGPreqcancel.so >> $LOG 2>&1
cp /s/vendor/lib64/libGPreqcancel_svc.so >> $LOG 2>&1
cp /s/vendor/lib64/libqdutils.so >> $LOG 2>&1
cp /s/vendor/lib64/libqisl.so >> $LOG 2>&1
cp /s/vendor/lib64/libqservice.so >> $LOG 2>&1
cp /s/vendor/lib64/librecovery_updater_msm.so >> $LOG 2>&1
cp /s/vendor/lib64/libsecureui.so >> $LOG 2>&1
cp /s/vendor/lib64/libSecureUILib.so >> $LOG 2>&1
cp /s/vendor/lib64/libsecureui_svcsock.so >> $LOG 2>&1
cp /s/vendor/lib64/libspcom.so >> $LOG 2>&1
cp /s/vendor/lib64/libspl.so >> $LOG 2>&1
cp /s/vendor/lib64/libStDrvInt.so >> $LOG 2>&1
cp /s/vendor/lib64/libkeymasterdeviceutils.so >> $LOG 2>&1
cp /s/vendor/lib64/libkeymasterprovision.so >> $LOG 2>&1
cp /s/vendor/lib64/libkeymasterutils.so >> $LOG 2>&1
cp /s/vendor/lib64/vendor.qti.hardware.tui_comm@1.0_vendor.so >> $LOG 2>&1


F_LOG "preparing libraries finished"

umount /s >> $LOG 2>&1 || F_ELOG "unmounting /s failed"

# inform init to start qseecomd
setprop crypto.ready 1  >> $LOG 2>&1 
F_LOG "crypto.ready: $(getprop crypto.ready)"

F_LOG "current mounts: \n$(mount)"

F_LOG "$0 ended"
exit 0
