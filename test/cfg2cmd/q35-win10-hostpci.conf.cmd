/usr/bin/kvm \
  -id 8006 \
  -name vm8006 \
  -no-shutdown \
  -chardev 'socket,id=qmp,path=/var/run/qemu-server/8006.qmp,server=on,wait=off' \
  -mon 'chardev=qmp,mode=control' \
  -chardev 'socket,id=qmp-event,path=/var/run/qmeventd.sock,reconnect=5' \
  -mon 'chardev=qmp-event,mode=control' \
  -pidfile /var/run/qemu-server/8006.pid \
  -daemonize \
  -smbios 'type=1,uuid=3dd750ce-d910-44d0-9493-525c0be4e687' \
  -drive 'if=pflash,unit=0,format=raw,readonly=on,file=/usr/share/pve-edk2-firmware//OVMF_CODE.fd' \
  -drive 'if=pflash,unit=1,format=qcow2,id=drive-efidisk0,file=/var/lib/vz/images/100/vm-100-disk-1.qcow2' \
  -smp '2,sockets=2,cores=1,maxcpus=2' \
  -nodefaults \
  -boot 'menu=on,strict=on,reboot-timeout=1000,splash=/usr/share/qemu-server/bootsplash.jpg' \
  -vnc 'unix:/var/run/qemu-server/8006.vnc,password=on' \
  -no-hpet \
  -cpu 'kvm64,enforce,hv_ipi,hv_relaxed,hv_reset,hv_runtime,hv_spinlocks=0x1fff,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vpindex,+kvm_pv_eoi,+kvm_pv_unhalt,+lahf_lm,+sep' \
  -m 512 \
  -object 'memory-backend-ram,id=ram-node0,size=256M' \
  -numa 'node,nodeid=0,cpus=0,memdev=ram-node0' \
  -object 'memory-backend-ram,id=ram-node1,size=256M' \
  -numa 'node,nodeid=1,cpus=1,memdev=ram-node1' \
  -readconfig /usr/share/qemu-server/pve-q35-4.0.cfg \
  -device 'vmgenid,guid=54d1c06c-8f5b-440f-b5b2-6eab1380e13d' \
  -device 'usb-tablet,id=tablet,bus=ehci.0,port=1' \
  -device 'vfio-pci,host=0000:f0:42.0,id=hostpci0,bus=pci.0,addr=0x10' \
  -device 'vfio-pci,host=0000:f0:43.0,id=hostpci1,bus=ich9-pcie-port-2,addr=0x0' \
  -device 'pcie-root-port,id=ich9-pcie-port-5,addr=10.0,x-speed=16,x-width=32,multifunction=on,bus=pcie.0,port=5,chassis=5' \
  -device 'vfio-pci,host=0000:00:43.1,id=hostpci4,bus=ich9-pcie-port-5,addr=0x0' \
  -device 'VGA,id=vga,bus=pcie.0,addr=0x1' \
  -device 'virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x3' \
  -iscsi 'initiator-name=iqn.1993-08.org.debian:01:aabbccddeeff' \
  -netdev 'type=tap,id=net0,ifname=tap8006i0,script=/var/lib/qemu-server/pve-bridge,downscript=/var/lib/qemu-server/pve-bridgedown,vhost=on' \
  -device 'virtio-net-pci,mac=2E:01:68:F9:9C:87,netdev=net0,bus=pci.0,addr=0x12,id=net0,bootindex=300' \
  -rtc 'driftfix=slew,base=localtime' \
  -machine 'type=pc-q35-5.1+pve0' \
  -global 'kvm-pit.lost_tick_policy=discard'
