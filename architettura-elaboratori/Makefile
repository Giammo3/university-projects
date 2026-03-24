AS_FLAGS = --32
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/read_file.o obj/print_text.o obj/view_menu.o obj/edf.o obj/hpf.o obj/print_algorithm.o obj/tostring.o
	ld $(LD_FLAGS) obj/main.o obj/read_file.o obj/print_text.o obj/view_menu.o obj/edf.o obj/hpf.o obj/print_algorithm.o obj/tostring.o -o bin/pianificatore

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/read_file.o: src/read_file.s
	as $(AS_FLAGS) $(DEBUG) src/read_file.s -o obj/read_file.o

obj/print_text.o: src/print_text.s
	as $(AS_FLAGS) $(DEBUG) src/print_text.s -o obj/print_text.o

obj/view_menu.o: src/view_menu.s
	as $(AS_FLAGS) $(DEBUG) src/view_menu.s -o obj/view_menu.o

obj/edf.o: src/edf.s
	as $(AS_FLAGS) $(DEBUG) src/edf.s -o obj/edf.o

obj/hpf.o: src/hpf.s
	as $(AS_FLAGS) $(DEBUG) src/hpf.s -o obj/hpf.o

obj/print_algorithm.o: src/print_algorithm.s
	as $(AS_FLAGS) $(DEBUG) src/print_algorithm.s -o obj/print_algorithm.o

obj/tostring.o: src/tostring.s
	as $(AS_FLAGS) $(DEBUG) src/tostring.s -o obj/tostring.o

clean:
	rm -f obj/*.o bin/pianificatore
