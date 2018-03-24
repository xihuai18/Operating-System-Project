@echo off

nasm -f bin .\loader.asm -o loader.bin > log.txt
nasm -f elf32 .\boot.asm -o boot.o > log.txt
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c .\utils.c -o utils.o > log.txt
ld -m i386pe -N .\utils.o .\boot.o -Ttext 0x8100 -o boot.tmp > log.txt
objcopy -O binary boot.tmp boot.bin > log.txt

type log.txt |find "Error"
type log.txt |find "Warn"

dd if=loader.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=boot.bin of=boot.img bs=512 seek=1 count=20 conv=notrunc

copy .\boot.img e:\bochs-2.6.9
cd E:\Bochs-2.6.9
if "%1" == "run"  bochs.exe -qf "E:\Bochs-2.6.9\bochsrc"
if "%1" == "debug" 	bochsdbg.exe -qf "E:\Bochs-2.6.9\bochsrc"