# A DECOMMENTER POUR AUGMENTER LA VITESSE
#NEED_FOR_SPEED := 1

FLAGS := -use-ocamlfind -j 0 -ocamlopt ocamlopt.opt -ocamlc ocamlc.opt -log out.log

ifdef NEED_FOR_SPEED
	FLAGS := $(FLAGS) -cflags -noassert,-unsafe,-rectypes -tag "incline(1000)"
	OPTFLAGS := -cflags -nodynlink,-ffast-math
endif

INC := -I src -I src/building -I src/talking -I src/thinking
PKG := -pkg batteries

CC := ocamlbuild
COMPILE := $(CC) $(FLAGS) $(PKG) $(INC)

TEST_FLAGS := -pkg oUnit -I test -I test/utils

all: speed_test
exe: native

native:
	$(COMPILE) main.native
bytecode:
	$(COMPILE) main.byte
debug:
	$(COMPILE) main.d.byte

speed_test: native
	@echo "****************************************"
	@echo "Compiling regression test..."
	@$(COMPILE) $(TEST_FLAGS) -quiet testing.native
	@echo "Beginning speed tests..."
	@./testing.native
	@echo
	@echo "****************************************"

test: speed_test
	@echo "****************************************"
	@echo "Compiling long running test..."
	@$(COMPILE) $(TEST_FLAGS) -quiet long_testing.native
	@echo "Beginning long running test..."
	@./long_testing.native
	@echo
	@echo "****************************************"

clean:
	ocamlbuild -clean
