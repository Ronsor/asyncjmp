HOSTCC ?= cc

CC = $(WASI_SDK_PATH)/bin/clang
AR = $(WASI_SDK_PATH)/bin/llvm-ar
WASM_OPT := wasm-opt

CFLAGS = -I.
LDFLAGS =

C_SRC = \
  machine.c \
  runtime.c \
  setjmp.c

ASM_SRC = \
  machine_core.S \
  setjmp_core.S

TEST_C_SRC = \
  test.c

OBJ = $(C_SRC:.c=.o) $(ASM_SRC:.S=.o)
TEST_OBJ = $(TEST_C_SRC:.c=.o)

lib: libasyncjmp.a
app: test_async.wasm
native_app: test_native

libasyncjmp.a: $(OBJ)
	$(AR) crs $@ $(OBJ)

test.wasm: libasyncjmp.a $(TEST_OBJ)
	$(CC) $(LDFLAGS) -o $@ $(TEST_OBJ) libasyncjmp.a

test_async.wasm: test.wasm
	$(WASM_OPT) --asyncify $< -o $@

test_native: $(TEST_C_SRC)
	$(HOSTCC) -o $@ $(TEST_C_SRC)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.S.o:
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.a *.wasm test_native
