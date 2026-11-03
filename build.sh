#!/bin/sh
set -e
cd "$(dirname "$0")"
T=/workspace/symmetry-visualizations/toolchain/usr
export LD_LIBRARY_PATH=/workspace/symmetry-visualizations/toolchain/lib
LD=$(command -v wasm-ld || echo /tmp/bin/wasm-ld-19)
mkdir -p obj && cd obj && rm -f *.o
"$T/bin/llvm-gcc" -c --target=wasm32 -O2 -gnat2012 -gnatp -gnatwa -gnatwe --RTS="$T/lib/rts-native" -I../src ../src/irl.adb
ar x "$T/lib/rts-native/adalib/libgnat.a" s-memcop.o s-memmov.o s-memset.o
"$LD" --no-entry --strip-all --export=irl_grid --export=irl_image --export=irl_init --export=irl_render --export=irl_height --export=irl_version --initial-memory=16777216 -o irl.wasm *.o
ls -la irl.wasm
