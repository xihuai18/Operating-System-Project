.\nasm.exe -f bin boot.asm -o boot.bin
dd if=boot.bin of=boot.img bs=1M count=1 conv=notrunc
cd E:\Bochs-2.6.9
rem bochs.exe -qf E:\Bochs-2.6.9\bochsrc