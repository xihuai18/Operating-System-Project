@echo off

.\nasm.exe -f bin .\boot.asm -o boot.bin > log.txt
.\nasm.exe -f bin .\ball_A.asm -o ball_A.bin > log.txt 
.\nasm.exe -f bin .\ball_B.asm -o ball_B.bin > log.txt
.\nasm.exe -f bin .\ball_C.asm -o ball_C.bin > log.txt
.\nasm.exe -f bin .\ball_D.asm -o ball_D.bin > log.txt
.\nasm.exe -f bin .\showBall.asm -o showBall.bin > log.txt
.\nasm.exe -f bin .\printnames.asm -o printnames.bin > log.txt 
.\nasm.exe -f bin .\cleanPrint.asm -o cleanPrint.bin > log.txt
.\nasm.exe -f bin .\checkinput.asm -o checkinput.bin > log.txt
.\nasm.exe -f bin .\printBigName.asm -o printBigName.bin > log.txt

type log.txt |find "Error"
type log.txt |find "Warn"


dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=ball_A.bin of=boot.img bs=512 seek=1 count=1 conv=notrunc
dd if=ball_B.bin of=boot.img bs=512 seek=2 count=1 conv=notrunc
dd if=ball_C.bin of=boot.img bs=512 seek=3 count=1 conv=notrunc
dd if=ball_D.bin of=boot.img bs=512 seek=4 count=1 conv=notrunc
dd if=showBall.bin of=boot.img bs=512 seek=5 count=1 conv=notrunc
dd if=printnames.bin of=boot.img bs=512 seek=6 count=1 conv=notrunc
dd if=checkinput.bin of=boot.img bs=512 seek=7 count=1 conv=notrunc
dd if=cleanPrint.bin of=boot.img bs=512 seek=8 count=1 conv=notrunc
dd if=printBigName.bin of=boot.img bs=512 seek=9 count=6 conv=notrunc

copy .\boot.img e:\bochs\bochs-2.6.9
cd E:\Bochs\Bochs-2.6.9
if "%1" == "run"  bochs.exe -qf "E:\Bochs\Bochs-2.6.9\bochsrc"
if "%1" == "debug" 	bochsdbg.exe -qf "E:\Bochs\Bochs-2.6.9\bochsrc"