@echo off

.\nasm.exe -f bin .\loader.asm -o loader.bin > log.txt
.\nasm.exe -f bin .\ball_A.asm -o ball_A.bin > log.txt 
.\nasm.exe -f bin .\ball_B.asm -o ball_B.bin > log.txt
.\nasm.exe -f bin .\ball_C.asm -o ball_C.bin > log.txt
.\nasm.exe -f bin .\ball_D.asm -o ball_D.bin > log.txt
.\nasm.exe -f bin .\showBall.asm -o showBall.bin > log.txt
.\nasm.exe -f bin .\printnames.asm -o printnames.bin > log.txt 
.\nasm.exe -f bin .\cleanPrint.asm -o cleanPrint.bin > log.txt
.\nasm.exe -f bin .\checkinput.asm -o checkinput.bin > log.txt
.\nasm.exe -f bin .\printBigName.asm -o printBigName.bin > log.txt
.\nasm.exe -f elf32 .\utils.asm -o utils.o > log.txt
rem gcc -Wa,-R -O -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\os.c -o os.o > log.txt
rem gcc -Wa,-R -O -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\utilsC.c -o utilsC.o > log.txt
gcc -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\os.c -o os.o > log.txt
gcc -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\utilsC.c -o utilsC.o > log.txt
rem ld -m i386pe -N .\os.o .\utils.o .\utilsC.o  -Ttext 0x7f00 -Tdata 0x9900 -o boot.tmp > log.txt
ld -m i386pe -N .\os.o .\utils.o .\utilsC.o  -T linkscript -o boot.tmp > log.txt
objcopy -O binary boot.tmp boot.bin > log.txt

type log.txt |find "Error"
type log.txt |find "Warn"

dd if=loader.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=boot.bin of=boot.img bs=512 seek=1 count=31 conv=notrunc
rem 1磁头0柱面
dd if=showBall.bin of=boot.img bs=512 seek=32 count=1 conv=notrunc
dd if=printnames.bin of=boot.img bs=512 seek=33 count=1 conv=notrunc
dd if=checkinput.bin of=boot.img bs=512 seek=34 count=1 conv=notrunc
dd if=cleanPrint.bin of=boot.img bs=512 seek=35 count=1 conv=notrunc
rem 0磁头1柱面
dd if=ball_A.bin of=boot.img bs=512 seek=36 count=1 conv=notrunc
dd if=ball_B.bin of=boot.img bs=512 seek=37 count=1 conv=notrunc
dd if=ball_C.bin of=boot.img bs=512 seek=38 count=1 conv=notrunc
dd if=ball_D.bin of=boot.img bs=512 seek=39 count=1 conv=notrunc
dd if=printBigName.bin of=boot.img bs=512 seek=40 count=6 conv=notrunc
dd if=fileRecords.txt of=boot.img bs=512 seek=46 count=2 conv=notrunc
dd if=manual.txt of=boot.img bs=512 seek=48 count=6 conv=notrunc


copy .\boot.img e:\bochs-2.6.9
cd E:\Bochs-2.6.9
if "%1" == "run"  bochs.exe -qf "E:\Bochs-2.6.9\bochsrc"
if "%1" == "debug" 	bochsdbg.exe -qf "E:\Bochs-2.6.9\bochsrc"

rem objdump.exe -D -Mintel i8086 -b binary -m i386  .\loader.bin

rem del *.bin, *.o