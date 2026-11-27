// Best Face SNAP shim for SM8250 (ssch71). The S23 faceswap models are weight-stripped HTP
// caches that cannot load on the V66 DSP, so both models are emulated on the CPU here.
// Every other model is forwarded to libsnap_aidl.snap.samsung.so unchanged.
typedef unsigned long size_t; typedef unsigned long uint64_t; typedef unsigned char u8;
void *dlopen(const char*,int); void *dlsym(void*,const char*);
int __android_log_print(int,const char*,const char*,...);
void *malloc(size_t); void free(void*); void *memcpy(void*,const void*,size_t);
int pthread_mutex_lock(void*); struct ts{long s,n;}; int clock_gettime(int,struct ts*);
static double nowt(void){ struct ts t; clock_gettime(1,&t); return t.s+t.n*1e-9; } int pthread_mutex_unlock(void*);
#define LOG(...) __android_log_print(4,"BFSW",__VA_ARGS__)
#include "fs.h"
#define NSLOT 33
static void *real; static void **realvt; static void *ourvt[NSLOT]; static long mtx[8];
typedef int (*open_fn)(void*,void*); typedef int (*exec_fn)(void*,void*,void*);
struct dbuf { void *data; int *sb,*se,*sc; uint64_t extra; };
struct vec { struct dbuf *b,*e,*c; };
#define MAXS 16
static void *sess[MAXS]; static int stype[MAXS]; static float *sbuf[MAXS];
static int has(const char *s,const char *t){ for(;*s;s++){ const char *a=s,*b=t; while(*a&&*b&&*a==*b){a++;b++;} if(!*b) return 1; } return 0; }
static void lstr(const u8 *p,char *out,int max){ int n; const char *d;
    if(!(p[0]&1)){ n=p[0]>>1; d=(const char*)p+1; } else { n=(int)*(size_t*)(p+8); d=*(const char**)(p+16); }
    if(n<0||n>=max||!d){ out[0]=0; return; } memcpy(out,d,n); out[n]=0; }
static int find(void *s){ for(int i=0;i<MAXS;i++) if(sess[i]==s) return i; return -1; }
static int h_open(void *self,void *opt){
    char nm[128]; lstr((const u8*)opt+0xf0,nm,128); int t= has(nm,"faceswapOptical")?1 : has(nm,"faceswapFusion")?2 : 0;
    pthread_mutex_lock(mtx); int i=find(self); if(i<0) for(i=0;i<MAXS&&sess[i];i++); if(i<MAXS){ sess[i]=self; stype[i]=t; } pthread_mutex_unlock(mtx);
    if(t){ LOG("Open %s: CPU replacement",nm); return 0; }
    return ((open_fn)realvt[7])(self,opt);
}
// debug.bfsw.dump=1: write every faceswap model input and output as raw float32 tensors to the app's
// cache dir (/data/user/0/<package>/cache/bfsw), to tune the replacement against real frames.
int __system_property_get(const char*,char*);
int open(const char*,int,...); long write(int,const void*,size_t); long read(int,void*,size_t); int close(int);
int mkdir(const char*,unsigned); int snprintf(char*,size_t,const char*,...);
static int dumpn;
static int dump_dir(char *d,int max){ char v[92]; v[0]=0; __system_property_get("debug.bfsw.dump",v); if(v[0]!='1') return 0;
    char pk[128]; int fd=open("/proc/self/cmdline",0); if(fd<0) return 0; long r=read(fd,pk,sizeof(pk)-1); close(fd); if(r<=0) return 0; pk[r]=0;
    snprintf(d,max,"/data/user/0/%s/cache/bfsw",pk); mkdir(d,0700); return 1; }
static void dump_buf(const char *d,int n,const char *tag,int k,const float *p,int h,int w,int c){ char f[256];
    snprintf(f,sizeof(f),"%s/%03d_%s_%d_%dx%dx%d.f32",d,n,tag,k,h,w,c); int fd=open(f,0x241,0600); if(fd<0){ LOG("dump: cannot write %s",f); return; }
    long len=(long)h*w*c*4; const char *q=(const char*)p; while(len>0){ long r=write(fd,q,len>(1<<20)?(1<<20):len); if(r<=0) break; q+=r; len-=r; } close(fd); }
static int dims(struct dbuf *b,int *h,int *w,int *c){ int n=(int)(b->se-b->sb); if(n!=4) return 0; *h=b->sb[1]; *w=b->sb[2]; *c=b->sb[3]; return 1; }
static int h_exec(void *self,void *vin,void *vout){
    pthread_mutex_lock(mtx); int i=find(self); int t= i>=0?stype[i]:0; pthread_mutex_unlock(mtx);
    if(!t) return ((exec_fn)realvt[3])(self,vin,vout);
    struct vec *in=(struct vec*)vin,*out=(struct vec*)vout; int n=(int)(in->e-in->b), h,w,c;
    if(!dims(&in->b[0],&h,&w,&c)){ LOG("bad input rank"); return -1; }
    int oc= t==1?8:3; float *o=fa((long)h*w*oc); double t0=nowt();
    if(t==1){ if(n<4){ LOG("Optical: %d inputs",n); free(o); return -1; }
        fs_optical((float*)in->b[0].data,(float*)in->b[1].data,(float*)in->b[2].data,(float*)in->b[3].data,w,h,o); }
    else { if(c!=8){ LOG("Fusion: %d channels",c); free(o); return -1; } fs_fusion((float*)in->b[0].data,w,h,o); }
    { char d[200]; if(dump_dir(d,sizeof(d))){ int dn=__atomic_fetch_add(&dumpn,1,0); const char *tg=t==1?"opt":"fus";
        for(int k=0;k<n;k++){ int hh,ww,cc; if(dims(&in->b[k],&hh,&ww,&cc)) dump_buf(d,dn,tg,k,(float*)in->b[k].data,hh,ww,cc); }
        dump_buf(d,dn,tg,9,o,h,w,oc); LOG("dump: %s/%03d_%s_*",d,dn,tg); } }
    struct dbuf *db=(struct dbuf*)malloc(sizeof(struct dbuf)); int *sh=(int*)malloc(4*sizeof(int));
    sh[0]=1; sh[1]=h; sh[2]=w; sh[3]=oc; db->data=o; db->sb=sh; db->se=sh+4; db->sc=sh+4; db->extra=0x100000000UL;
    out->b=db; out->e=db+1; out->c=db+1;
    pthread_mutex_lock(mtx); if(sbuf[i]) free(sbuf[i]); sbuf[i]=o; pthread_mutex_unlock(mtx);
    LOG("Execute %s %dx%d ok %.0f ms",t==1?"Optical":"Fusion",w,h,(nowt()-t0)*1000);
    return 0;
}
// ArcSoft's internal logger (Cur Fusion Score, mask validity, error paths) prints only through a
// callback pointer that the Best Face engine never sets. With debug.bfsw.arclog=1, point it at
// logcat (tag ArcSoftPB). Offsets are for the One UI 9 S911N libgallery_pic_best.arcsoft.so and
// are checked against the relocated GOT slot first, so any other build is left alone. The engine
// dlcloses this library after every model run while the callback stays set, so it is linked with
// -z nodelete and never unmapped.
int __system_property_get(const char*,char*);
static void arclog(const char *m){ __android_log_print(4,"ArcSoftPB","%s",m); }
static void hook_arclog(void){ static int done; char v[92]; if(done) return; done=1;
    v[0]=0; __system_property_get("debug.bfsw.arclog",v); if(v[0]!='1') return;
    void *h=dlopen("libgallery_pic_best.arcsoft.so",2|4); if(!h){ LOG("arclog: engine not loaded"); return; }
    char *f=(char*)dlsym(h,"ARC_GPB_SetLogLevel"); if(!f) return; char *base=f-0x3245b30;
    void **got=(void**)(base+0x3586b58);
    if(*got!=(void*)(base+0xda088a8)){ LOG("arclog: unknown engine build"); return; }
    *(void**)(base+0xda088a8)=(void*)arclog; LOG("arclog: ArcSoft log -> ArcSoftPB"); }
static void init(void){ if(!real) real=dlopen("libsnap_aidl.snap.samsung.so",2); hook_arclog(); }
typedef void *(*cs_fn)(void*,void*,void*,void*,void*,void*,void*,void*);
static void *wrap(void *o){ if(!o) return o; void **vt=*(void***)o;
    pthread_mutex_lock(mtx);
    if(!realvt){ realvt=vt; for(int i=0;i<NSLOT;i++) ourvt[i]=vt[i]; ourvt[7]=(void*)h_open; ourvt[3]=(void*)h_exec; }
    if(vt==realvt) *(void***)o=ourvt;
    pthread_mutex_unlock(mtx); return o; }
void *CreateSnapSession(void*a,void*b,void*c,void*d,void*e,void*f,void*g,void*h){
    init(); cs_fn fn=(cs_fn)dlsym(real,"CreateSnapSession"); return wrap(fn?fn(a,b,c,d,e,f,g,h):0); }
void *CreateSnapSecureSession(void*a,void*b,void*c,void*d,void*e,void*f,void*g,void*h){
    init(); cs_fn fn=(cs_fn)dlsym(real,"CreateSnapSecureSession"); return wrap(fn?fn(a,b,c,d,e,f,g,h):0); }
void *DestroySnapSession(void*a,void*b,void*c,void*d,void*e,void*f,void*g,void*h){
    pthread_mutex_lock(mtx); int i=find(a); if(i>=0){ sess[i]=0; stype[i]=0; if(sbuf[i]) free(sbuf[i]); sbuf[i]=0; } pthread_mutex_unlock(mtx);
    init(); cs_fn fn=(cs_fn)dlsym(real,"DestroySnapSession"); return fn?fn(a,b,c,d,e,f,g,h):0; }
#define FWD(n) void *n(void*a,void*b,void*c,void*d,void*e,void*f,void*g,void*h){ init(); cs_fn fn=(cs_fn)dlsym(real,#n); return fn?fn(a,b,c,d,e,f,g,h):0; }
FWD(CreateSnapInfo) FWD(DestroySnapInfo)
