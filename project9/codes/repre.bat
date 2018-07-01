@echo off
qemu-system-i386 -boot order=a -m 1M -drive format=raw,index=0,if=floppy,file=..\imgs\boot.img