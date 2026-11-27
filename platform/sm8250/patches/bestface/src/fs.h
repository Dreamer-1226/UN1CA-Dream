// Best Face face-swap replacement for SM8250 (no HTP). ssch71
// Optical: pyramidal Lucas-Kanade flow held to a robust affine fit plus a small smooth residual, + bilinear warp. Fusion: Poisson membrane blend + feather.
static float *fa(long n){ return (float*)malloc(n*sizeof(float)); }
static void fz(float *p,long n){ for(long i=0;i<n;i++) p[i]=0; }
static int clampi(int v,int lo,int hi){ return v<lo?lo:(v>hi?hi:v); }
static float flr(float x){ int i=(int)x; return (float)(x<i?i-1:i); }
static void boxh(const float *s,float *d,int w,int h,int r){
    for(int y=0;y<h;y++){ const float *row=s+(long)y*w; float *o=d+(long)y*w; float acc=0;
        for(int k=-r;k<=r;k++) acc+=row[clampi(k,0,w-1)];
        for(int x=0;x<w;x++){ o[x]=acc/(2*r+1); acc+=row[clampi(x+r+1,0,w-1)]-row[clampi(x-r,0,w-1)]; } } }
static void boxv(const float *s,float *d,int w,int h,int r){
    for(int x=0;x<w;x++){ float acc=0;
        for(int k=-r;k<=r;k++) acc+=s[(long)clampi(k,0,h-1)*w+x];
        for(int y=0;y<h;y++){ d[(long)y*w+x]=acc/(2*r+1); acc+=s[(long)clampi(y+r+1,0,h-1)*w+x]-s[(long)clampi(y-r,0,h-1)*w+x]; } } }
static void boxf(float *a,float *t,int w,int h,int r,int passes){ for(int p=0;p<passes;p++){ boxh(a,t,w,h,r); boxv(t,a,w,h,r);} }
static float bil(const float *img,int w,int h,int c,int ch,float x,float y,int rep){
    float fx=flr(x), fy=flr(y); int x0=(int)fx,y0=(int)fy; float ax=x-fx, ay=y-fy; float v[4]; int k=0;
    for(int dy=0;dy<2;dy++) for(int dx=0;dx<2;dx++){ int xx=x0+dx,yy=y0+dy;
        if(xx<0||yy<0||xx>=w||yy>=h){ if(!rep){ v[k++]=0; continue;} xx=clampi(xx,0,w-1); yy=clampi(yy,0,h-1);} v[k++]=img[((long)yy*w+xx)*c+ch]; }
    return (v[0]*(1-ax)+v[1]*ax)*(1-ay)+(v[2]*(1-ax)+v[3]*ax)*ay;
}
static void down2(const float *s,int w,int h,float *d){ int W=w/2,H=h/2;
    for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)2*y*w+2*x; d[(long)y*W+x]=0.25f*(s[i]+s[i+1]+s[i+w]+s[i+w+1]); } }

// Robust affine fit u = a0+a1 x+a2 y (same for v), weighted by local texture and Huber-reweighted.
static void solve3(double M[3][4],double *x){
    for(int c=0;c<3;c++){ int p=c; for(int r=c+1;r<3;r++) if((M[r][c]<0?-M[r][c]:M[r][c])>(M[p][c]<0?-M[p][c]:M[p][c])) p=r;
        for(int k=0;k<4;k++){ double t=M[c][k]; M[c][k]=M[p][k]; M[p][k]=t; }
        if(M[c][c]<1e-12&&M[c][c]>-1e-12){ x[0]=x[1]=x[2]=0; return; }
        for(int r=0;r<3;r++) if(r!=c){ double f=M[r][c]/M[c][c]; for(int k=c;k<4;k++) M[r][k]-=f*M[c][k]; } }
    for(int i=0;i<3;i++) x[i]=M[i][3]/M[i][i]; }
static void affine_fit(const float *u,const float *v,const float *wt,int W,int H,float hub,double *pa,double *pb){
    pa[0]=pa[1]=pa[2]=pb[0]=pb[1]=pb[2]=0;
    for(int it=0;it<5;it++){ double Ma[3][4]={{0}},Mb[3][4]={{0}};
        for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; double w=wt[i]; if(w<=0) continue;
            if(it){ double ru=u[i]-(pa[0]+pa[1]*x+pa[2]*y), rv=v[i]-(pb[0]+pb[1]*x+pb[2]*y), r=__builtin_sqrt(ru*ru+rv*rv); if(r>hub) w*=hub/r; }
            double f[3]={1,(double)x,(double)y};
            for(int a=0;a<3;a++){ for(int b=0;b<3;b++){ Ma[a][b]+=w*f[a]*f[b]; Mb[a][b]+=w*f[a]*f[b]; } Ma[a][3]+=w*f[a]*u[i]; Mb[a][3]+=w*f[a]*v[i]; } }
        solve3(Ma,pa); solve3(Mb,pb); } }
static void lkflow(const float *g0,const float *g1,int w,int h,float *fx,float *fy){
    enum{ LV=5, IT=8, R=7, SR=6 };
    long NN=(long)w*h; float *n0=fa(NN),*n1=fa(NN);
    { double m0=0,m1=0,s0=0,s1=0; for(long i=0;i<NN;i++){ m0+=g0[i]; m1+=g1[i]; } m0/=NN; m1/=NN;
      for(long i=0;i<NN;i++){ s0+=(g0[i]-m0)*(g0[i]-m0); s1+=(g1[i]-m1)*(g1[i]-m1); } s0=__builtin_sqrt(s0/NN)+1e-6; s1=__builtin_sqrt(s1/NN)+1e-6;
      for(long i=0;i<NN;i++){ n0[i]=(g0[i]-m0)/s0; n1[i]=(g1[i]-m1)/s1; } }
    const float *P0[LV],*P1[LV]; int PW[LV],PH[LV]; P0[0]=n0;P1[0]=n1;PW[0]=w;PH[0]=h;
    for(int l=1;l<LV;l++){ PW[l]=PW[l-1]/2; PH[l]=PH[l-1]/2; float *a=fa((long)PW[l]*PH[l]),*b=fa((long)PW[l]*PH[l]);
        down2(P0[l-1],PW[l-1],PH[l-1],a); down2(P1[l-1],PW[l-1],PH[l-1],b); P0[l]=a;P1[l]=b; }
    long N=(long)w*h; float *u=fa(N),*v=fa(N),*nu=fa(N),*nv=fa(N),*bw=fa(N),*A=fa(N),*B=fa(N),*C=fa(N),*D=fa(N),*E=fa(N),*T=fa(N);
    int cw=PW[LV-1],chh=PH[LV-1];
    // Start from the best global shift on the coarsest level (exhaustive, +-SR pixels there), so a face
    // that moved further than the pyramid can follow still converges.
    { const float *a=P0[LV-1],*b=P1[LV-1]; double best=1e30; int bx=0,by=0, m=cw/8;
      for(int dy=-SR;dy<=SR;dy++) for(int dx=-SR;dx<=SR;dx++){ double e=0; long c=0;
          for(int y=m;y<chh-m;y++){ int yy=y+dy; if(yy<0||yy>=chh) continue;
              for(int x=m;x<cw-m;x++){ int xx=x+dx; if(xx<0||xx>=cw) continue; double d=b[(long)yy*cw+xx]-a[(long)y*cw+x]; e+=d*d; c++; } }
          if(c>(long)(cw-2*m)*(chh-2*m)/3){ e/=c; if(e<best){ best=e; bx=dx; by=dy; } } }
      for(long i=0;i<(long)cw*chh;i++){ u[i]=bx; v[i]=by; } }
    for(int l=LV-1;l>=0;l--){ int W=PW[l],H=PH[l]; long n=(long)W*H;
        if(l!=LV-1){ for(int y=0;y<H;y++) for(int x=0;x<W;x++){ int sx=clampi(x/2,0,cw-1), sy=clampi(y/2,0,chh-1);
                nu[(long)y*W+x]=2*u[(long)sy*cw+sx]; nv[(long)y*W+x]=2*v[(long)sy*cw+sx]; }
            for(long i=0;i<n;i++){ u[i]=nu[i]; v[i]=nv[i]; } cw=W; chh=H; }
        const float *a=P0[l],*b=P1[l];
        for(int it=0;it<IT;it++){
            for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; bw[i]=bil(b,W,H,1,0,x+u[i],y+v[i],1); }
            for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x;
                float ix=0.5f*(bw[(long)y*W+clampi(x+1,0,W-1)]-bw[(long)y*W+clampi(x-1,0,W-1)]);
                float iy=0.5f*(bw[(long)clampi(y+1,0,H-1)*W+x]-bw[(long)clampi(y-1,0,H-1)*W+x]);
                float itt=bw[i]-a[i]; A[i]=ix*ix; B[i]=ix*iy; C[i]=iy*iy; D[i]=ix*itt; E[i]=iy*itt; }
            boxf(A,T,W,H,R,1); boxf(B,T,W,H,R,1); boxf(C,T,W,H,R,1); boxf(D,T,W,H,R,1); boxf(E,T,W,H,R,1);
            float lim=0.25f*(W<H?W:H);
            for(long i=0;i<n;i++){ float reg=1e-2f*(A[i]+C[i])+1e-9f, a=A[i]+reg, c=C[i]+reg, det=a*c-B[i]*B[i];
                float du=-(c*D[i]-B[i]*E[i])/det, dv=-(a*E[i]-B[i]*D[i])/det; if(!(du==du)) du=0; if(!(dv==dv)) dv=0;
                if(du>2)du=2; if(du<-2)du=-2; if(dv>2)dv=2; if(dv<-2)dv=-2; u[i]+=du; v[i]+=dv;
                if(u[i]>lim)u[i]=lim; if(u[i]<-lim)u[i]=-lim; if(v[i]>lim)v[i]=lim; if(v[i]<-lim)v[i]=-lim; }
            boxf(u,T,W,H,1,1); boxf(v,T,W,H,1,1);
        }
        // The swap must move the candidate face as a whole onto the reference, not morph its expression:
        // keep a robust affine fit of the flow plus a small, smooth residual. Flat skin has no texture to
        // track, and unconstrained flow there wanders off and smears the lips over the chin.
        { double pa[3],pb[3]; float *cf=nu;
          for(long i=0;i<n;i++){ float tr=A[i]+C[i], df=A[i]-C[i]; float me=0.5f*(tr-__builtin_sqrtf(df*df+4*B[i]*B[i])); cf[i]=me>0?me:0; }
          affine_fit(u,v,cf,W,H,2.0f,pa,pb);
          float k=l==0?3.0f:1.5f;
          for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; float au=pa[0]+pa[1]*x+pa[2]*y, av=pb[0]+pb[1]*x+pb[2]*y;
              float ru=u[i]-au, rv=v[i]-av, r=__builtin_sqrtf(ru*ru+rv*rv); if(r>k){ ru*=k/r; rv*=k/r; }
              A[i]=ru; C[i]=rv; D[i]=au; E[i]=av; }
          boxf(A,T,W,H,4,2); boxf(C,T,W,H,4,2);
          for(long i=0;i<n;i++){ u[i]=D[i]+A[i]; v[i]=E[i]+C[i]; } }
    }
    for(long i=0;i<N;i++){ fx[i]=u[i]; fy[i]=v[i]; }
    for(int l=1;l<LV;l++){ free((void*)P0[l]); free((void*)P1[l]); }
    free(n0);free(n1);free(u);free(v);free(nu);free(nv);free(bw);free(A);free(B);free(C);free(D);free(E);free(T);
}
// in: i0,i1 HxWx3, m2,e2,m1 HxWx1 ; out HxWx8
static void fs_optical(const float *i0,const float *i1,const float *m2,const float *e2,int w,int h,float *out){
    long N=(long)w*h; float *g0=fa(N),*g1=fa(N),*fx=fa(N),*fy=fa(N);
    for(long i=0;i<N;i++){ g0[i]=0.114f*i0[3*i]+0.587f*i0[3*i+1]+0.299f*i0[3*i+2]; g1[i]=0.114f*i1[3*i]+0.587f*i1[3*i+1]+0.299f*i1[3*i+2]; }
    lkflow(g0,g1,w,h,fx,fy);
    for(int y=0;y<h;y++) for(int x=0;x<w;x++){ long i=(long)y*w+x; float sx=x+fx[i], sy=y+fy[i]; float *o=out+8*i;
        o[0]=i0[3*i]; o[1]=i0[3*i+1]; o[2]=i0[3*i+2];
        for(int c=0;c<3;c++) o[3+c]=bil(i1,w,h,3,c,sx,sy,0);
        o[6]=bil(m2,w,h,1,0,sx,sy,0); o[7]=bil(e2,w,h,1,0,sx,sy,0); }
    free(g0);free(g1);free(fx);free(fy);
}
// in HxWx8 (ArcSoft: i0, warped*mask, 1-mask, eye) ; out HxWx3
static void fs_fusion(const float *in,int w,int h,float *out){
    long N=(long)w*h; float *m=fa(N),*e=fa(N),*T=fa(N),*cc=fa(N),*wo=fa(N),*w2=fa(3*N),*fe=fa(N);
    int x0=w,y0=h,x1=-1,y1=-1;
    for(long i=0;i<N;i++){ const float *p=in+8*i; float a=1.0f-p[6]; m[i]=a;
        for(int c=0;c<3;c++) w2[3*i+c]= a>0.05f ? p[3+c]/a : p[c]; }
    // binary inside = (a>0.5) eroded by 4px
    for(long i=0;i<N;i++) T[i]=m[i]>0.5f?1.0f:0.0f;
    for(int y=0;y<h;y++) for(int x=0;x<w;x++){ float mn=1; for(int dy=-4;dy<=4&&mn>0;dy++) for(int dx=-4;dx<=4;dx++){ int xx=x+dx,yy=y+dy;
            if(xx<0||yy<0||xx>=w||yy>=h||T[(long)yy*w+xx]<0.5f){ mn=0; break; } }
        long i=(long)y*w+x; e[i]=mn; if(mn>0){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; } }
    float *res=fa(3*N);
    if(x1<0){ for(long i=0;i<N;i++) for(int c=0;c<3;c++) out[3*i+c]=in[8*i+c]; goto done; }
    for(long i=0;i<N;i++) wo[i]=1.0f-e[i];
    { float *ow=fa(N); for(long i=0;i<N;i++) ow[i]=wo[i]; boxf(ow,T,w,h,12,3);
      for(int c=0;c<3;c++){
        for(long i=0;i<N;i++) cc[i]=(in[8*i+c]-w2[3*i+c])*wo[i];
        boxf(cc,T,w,h,12,3);
        for(long i=0;i<N;i++){ float d=in[8*i+c]-w2[3*i+c]; cc[i]= e[i]>0 ? cc[i]/(ow[i]+1e-6f) : d; }
        int X0=clampi(x0-1,1,w-2),X1=clampi(x1+1,1,w-2),Y0=clampi(y0-1,1,h-2),Y1=clampi(y1+1,1,h-2);
        for(int k=0;k<300;k++) for(int par=0;par<2;par++)
            for(int y=Y0;y<=Y1;y++) for(int x=X0+((y+X0+par)&1);x<=X1;x+=2){ long i=(long)y*w+x; if(e[i]<=0) continue;
                float avg=0.25f*(cc[i-1]+cc[i+1]+cc[i-w]+cc[i+w]); cc[i]+=1.9f*(avg-cc[i]); }
        for(long i=0;i<N;i++) res[3*i+c]=w2[3*i+c]+cc[i];
      }
      free(ow); }
    for(long i=0;i<N;i++) fe[i]=e[i]; boxf(fe,T,w,h,3,3);
    for(long i=0;i<N;i++) for(int c=0;c<3;c++){ float f=fe[i]; float v=in[8*i+c]*(1-f)+res[3*i+c]*f; out[3*i+c]= v<0?0:(v>1?1:v); }
done:
    free(res); free(m);free(e);free(T);free(cc);free(wo);free(w2);free(fe);
}
