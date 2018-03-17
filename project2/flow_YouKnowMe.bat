.\nasm.exe -f bin boot.asm -o boot.bin
dd if=boot.bin of=boot.img bs=1M count=1 conv=notrunc
copy .\boot.img e:\bochs-2.6.8
cd E:\Bochs-2.6.8
bochsdbg.exe -qf E:\Bochs-2.6.8\bochsrc