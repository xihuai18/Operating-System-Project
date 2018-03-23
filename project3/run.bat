@echo off

nasm -f bin .\loader.asm -o loader.bin > log.txt
nasm -f elf32 .\utils.asm -o utils.o > log.txt
gcc -march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\os.c -o os.o > log.txt
gcc -march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\utilsC.c -o utilsC.o > log.txt
ld -m i386pe -N .\os.o .\utils.o .\utilsC.o  -Ttext 0x8100 -Tdata 0x9000 -o boot.tmp > log.txt
rem ld -m i386pe -N .\os.o .\utils.o .\utilsC.o  -Tlinkscript -o boot.tmp > log.txt
objcopy -O binary boot.tmp boot.bin > log.txt

type log.txt |find "Error"
type log.txt |find "Warn"

dd if=loader.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=boot.bin of=boot.img bs=512 seek=1 count=30 conv=notrunc

copy .\boot.img e:\bochs-2.6.9
cd E:\Bochs-2.6.9
if "%1" == "run"  bochs.exe -qf "E:\Bochs-2.6.9\bochsrc"
if "%1" == "debug" 	bochsdbg.exe -qf "E:\Bochs-2.6.9\bochsrc"