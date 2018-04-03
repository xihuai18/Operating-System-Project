@echo off

nasm.exe -f bin .\boot\loader.asm -o .\boot\loader.bin > log.txt
nasm.exe -f bin .\user\ball_A.asm -o .\user\ball_A.bin > log.txt 
nasm.exe -f bin .\user\ball_B.asm -o .\user\ball_B.bin > log.txt
nasm.exe -f bin .\user\ball_C.asm -o .\user\ball_C.bin > log.txt
nasm.exe -f bin .\user\ball_D.asm -o .\user\ball_D.bin > log.txt
nasm.exe -f bin .\userRoutine\showBall.asm -o .\userRoutine\showBall.bin > log.txt
nasm.exe -f bin .\userRoutine\printnames.asm -o .\userRoutine\printnames.bin > log.txt 
nasm.exe -f bin .\userRoutine\cleanPrint.asm -o .\userRoutine\cleanPrint.bin > log.txt
nasm.exe -f bin .\userRoutine\checkinput.asm -o .\userRoutine\checkinput.bin > log.txt
nasm.exe -f bin .\user\printBigName.asm -o .\user\printBigName.bin > log.txt
nasm.exe -f elf32 .\lib\utils.asm -o .\lib\utils.o > log.txt
rem gcc -Wa,-R -O -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\os.c -o os.o > log.txt
rem gcc -Wa,-R -O -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\utilsC.c -o utilsC.o > log.txt
gcc -Wa,-R -O -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\kernel\os.c -o .\kernel\os.o > log.txt
gcc -Wa,-R -march=i386 -g -m16 -mpreferred-stack-boundary=2 -ffreestanding -c .\lib\utilsC.c -o .\lib\utilsC.o > log.txt
rem ld -m i386pe -N .\os.o .\utils.o .\utilsC.o  -Ttext 0x7f00 -Tdata 0x9900 -o boot.tmp > log.txt
ld -m i386pe -N .\kernel\os.o .\lib\utils.o .\lib\utilsC.o  -T linkscript -o ..\imgs\boot.tmp > log.txt
objcopy -O binary ..\imgs\boot.tmp ..\imgs\boot.bin > log.txt

type log.txt |find "Error"
type log.txt |find "Warn"

dd if=.\boot\loader.bin of=..\imgs\boot.img bs=512 count=1 conv=notrunc
dd if=..\imgs\boot.bin of=..\imgs\boot.img bs=512 seek=1 count=31 conv=notrunc
rem 1磁头0柱面
dd if=.\userRoutine\showBall.bin of=..\imgs\boot.img bs=512 seek=32 count=1 conv=notrunc
dd if=.\userRoutine\printnames.bin of=..\imgs\boot.img bs=512 seek=33 count=1 conv=notrunc
dd if=.\userRoutine\checkinput.bin of=..\imgs\boot.img bs=512 seek=34 count=1 conv=notrunc
dd if=.\userRoutine\cleanPrint.bin of=..\imgs\boot.img bs=512 seek=35 count=1 conv=notrunc
rem 0磁头1柱面
dd if=.\user\ball_A.bin of=..\imgs\boot.img bs=512 seek=36 count=1 conv=notrunc
dd if=.\user\ball_B.bin of=..\imgs\boot.img bs=512 seek=37 count=1 conv=notrunc
dd if=.\user\ball_C.bin of=..\imgs\boot.img bs=512 seek=38 count=1 conv=notrunc
dd if=.\user\ball_D.bin of=..\imgs\boot.img bs=512 seek=39 count=1 conv=notrunc
dd if=.\user\printBigName.bin of=..\imgs\boot.img bs=512 seek=40 count=6 conv=notrunc
dd if=.\lib\fileRecords.txt of=..\imgs\boot.img bs=512 seek=46 count=2 conv=notrunc
dd if=.\lib\manual.txt of=..\imgs\boot.img bs=512 seek=48 count=6 conv=notrunc


rem copy ..\imgs\boot.img E:\bochs-2.6.9

if "%1" == "run"  bochs.exe -qf bochsrc
if "%1" == "debug" 	bochsdbg.exe -qf bochsrc

rem objdump.exe -D -Mintel i8086 -b binary -m i386  .\loader.bin

rem del *\*.bin, *\*.o