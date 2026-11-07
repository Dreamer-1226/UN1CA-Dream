// SPDX-License-Identifier: Apache-2.0
// Isolated ABI probe. Does not open cameras, calculate depth, or change calibration.
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <unistd.h>

typedef struct { void *data; int32_t bytes; int32_t padding; } Calibration;
_Static_assert(sizeof(Calibration) == 16, "arm64 calibration ABI");
typedef int32_t (*InitEx)(void **, int32_t, int32_t);
typedef int32_t (*SetCali)(void *, const Calibration *);
typedef int32_t (*Uninit)(void **);

int main(int argc, char **argv) {
    setbuf(stdout, NULL);
    struct rlimit core = {0, 0};
    setrlimit(RLIMIT_CORE, &core);
    alarm(25);
    if (argc != 3 || (argv[1][0] != '1' && argv[1][0] != '4') || argv[1][1]) {
        fprintf(stderr, "usage: calibration-loader {1|4} CALIBRATION_FILE\n"); return 64;
    }
    FILE *file = fopen(argv[2], "rb");
    unsigned char data[761];
    if (!file) { perror("calibration"); return 65; }
    size_t bytes = fread(data, 1, sizeof(data), file);
    int failed = ferror(file); fclose(file);
    if (failed || bytes != 760) { fprintf(stderr, "Expected exact 760-byte calibration\n"); return 65; }
    void *library = dlopen("/system/lib64/libdualcam_refocus_image.so", RTLD_NOW | RTLD_LOCAL);
    if (!library) { fprintf(stderr, "%s\n", dlerror()); return 66; }
    InitEx init = (InitEx)dlsym(library, "ARC_DCIR_InitEx");
    SetCali set = (SetCali)dlsym(library, "ARC_DCIR_SetCaliData");
    Uninit uninit = (Uninit)dlsym(library, "ARC_DCIR_Uninit");
    if (!init || !set || !uninit) { fprintf(stderr, "Required ABI missing\n"); return 66; }
    void *handle = NULL;
    int32_t rc = init(&handle, 1, atoi(argv[1]));
    printf("{\"event\":\"init\",\"mode\":%d,\"rc\":%d,\"handle_present\":%s}\n", atoi(argv[1]), rc, handle ? "true" : "false");
    int32_t accepted = -1;
    if (!rc && handle) {
        Calibration calibration = {data, 760, 0};
        accepted = set(handle, &calibration);
        printf("{\"event\":\"set_calibration\",\"rc\":%d,\"bytes\":760,\"depth_validated\":false}\n", accepted);
    }
    if (handle) {
        rc = uninit(&handle);
        printf("{\"event\":\"uninit\",\"rc\":%d,\"handle_present\":%s}\n", rc, handle ? "true" : "false");
    }
    dlclose(library);
    return accepted == 0 ? 0 : 1;
}
