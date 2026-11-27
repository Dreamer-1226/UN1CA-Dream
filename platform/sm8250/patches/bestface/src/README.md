libsnap_bfsw.snap.samsung.so is built from bfsw.c and fs.h without the NDK:

    printf 'void dlopen(){} void dlsym(){} void __android_log_print(){} void malloc(){} void free(){} void memcpy(){} void pthread_mutex_lock(){} void pthread_mutex_unlock(){} void clock_gettime(){} void __system_property_get(){} void open(){} void write(){} void read(){} void close(){} void mkdir(){} void snprintf(){}\n' > stubs.c
    for l in c dl log; do clang --target=aarch64-linux-android31 -w -fPIC -shared -nostdlib -Wl,-soname,lib$l.so stubs.c -o lib$l.so; done
    clang --target=aarch64-linux-android31 -O2 -w -fPIC -shared -nostdlib -fno-stack-protector -ffreestanding \
        -fuse-ld=lld -Wl,-soname,libsnap_bfsw.snap.samsung.so -Wl,--hash-style=both -Wl,-z,max-page-size=16384 -Wl,-z,nodelete \
        bfsw.c -L. -lc -ldl -llog -o libsnap_bfsw.snap.samsung.so
