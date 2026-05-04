ca65 main.s -g -o main.o
ld65 -o collapse.nes -C collapse.cfg main.o -m collapse.map.txt -Ln collapse.labels.txt --dbgfile collapse.nes.dbg