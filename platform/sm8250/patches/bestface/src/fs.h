// Best Face face-swap replacement for SM8250 (no HTP). ssch71
// Optical: dense inverse search (patch flow, coarse to fine) with Horn-Schunck refinement, held near a robust affine fit over the face, + bilinear warp. Fusion: Poisson membrane blend + feather.
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
// in: i0,i1 HxWx3, m2,e2,m1 HxWx1 ; out HxWx8
// Variational refinement (Horn-Schunck on the warped residual), as DIS does after densification: it
// spreads the reliable patch motion over weakly textured areas such as the lips instead of letting
// single patches smear them.
static void hsrefine(const float *a,const float *b,int W,int H,float *u,float *v,float al2,int iters,float *t1,float *t2,float *t3,float *t4,float *t5,float *t6){
    long n=(long)W*H; float *ix=t1,*iy=t2,*it=t3,*du=t4,*dv=t5,*bw=t6;
    for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; bw[i]=bil(b,W,H,1,0,x+u[i],y+v[i],1); }
    for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x;
        ix[i]=0.5f*(bw[(long)y*W+clampi(x+1,0,W-1)]-bw[(long)y*W+clampi(x-1,0,W-1)]);
        iy[i]=0.5f*(bw[(long)clampi(y+1,0,H-1)*W+x]-bw[(long)clampi(y-1,0,H-1)*W+x]);
        it[i]=bw[i]-a[i]; du[i]=0; dv[i]=0; }
    for(int k=0;k<iters;k++){
        for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x;
            long l=(long)y*W+clampi(x-1,0,W-1), r=(long)y*W+clampi(x+1,0,W-1), up=(long)clampi(y-1,0,H-1)*W+x, dn=(long)clampi(y+1,0,H-1)*W+x;
            // smoothness on the total flow u+du
            float mu=0.25f*(u[l]+du[l]+u[r]+du[r]+u[up]+du[up]+u[dn]+du[dn])-u[i];
            float mv=0.25f*(v[l]+dv[l]+v[r]+dv[r]+v[up]+dv[up]+v[dn]+dv[dn])-v[i];
            float num=ix[i]*mu+iy[i]*mv+it[i], den=al2+ix[i]*ix[i]+iy[i]*iy[i];
            du[i]=mu-ix[i]*num/den; dv[i]=mv-iy[i]*num/den; } }
    for(long i=0;i<n;i++){ u[i]+=du[i]; v[i]+=dv[i]; } }
// face weight of a level-l pixel, sampled from the full-resolution mask
static float WMs(const float *wm,int w,int W,long i){ int sc=w/W; int x=(int)(i%W)*sc, y=(int)(i/W)*sc; return wm[(long)y*w+x]>0.5f?1.0f:0.05f; }
// Dense inverse search (Kroeger et al. 2016, without the variational step): per pyramid level, every
// 8x8 patch on a 4 px grid is aligned to the candidate by inverse-compositional Gauss-Newton on
// mean-normalised intensities, starting from the coarser level's flow, and the patches are blended into
// a dense field weighted by how well each one explains each pixel. Robust to the softer focus and the
// exposure difference between burst frames, where pixel-wise Lucas-Kanade wandered.
static void disflow(const float *g0,const float *g1,const float *wm,int w,int h,float *fx,float *fy){
    enum{ LV=6, PS=8, ST=3, IT=16 };
    long NN=(long)w*h; float *n0=fa(NN),*n1=fa(NN);
    // match the two frames' brightness and contrast over the face (whole frame without a mask)
    { double s0=0,s1=0,q0=0,q1=0,ws=0; for(long i=0;i<NN;i++){ double wt=wm?(wm[i]>0.5f?1:0):1; s0+=wt*g0[i]; s1+=wt*g1[i]; q0+=wt*g0[i]*g0[i]; q1+=wt*g1[i]*g1[i]; ws+=wt; }
      if(ws<16) ws=1; double m0=s0/ws,m1=s1/ws, d0=__builtin_sqrt(q0/ws-m0*m0)+1e-6, d1=__builtin_sqrt(q1/ws-m1*m1)+1e-6;
      for(long i=0;i<NN;i++){ n0[i]=(float)((g0[i]-m0)/d0*0.2); n1[i]=(float)((g1[i]-m1)/d1*0.2); } }
    const float *P0[LV],*P1[LV]; int PW[LV],PH[LV]; P0[0]=n0;P1[0]=n1;PW[0]=w;PH[0]=h; int nl=1;
    for(int l=1;l<LV;l++){ if(PW[l-1]/2<24||PH[l-1]/2<24) break; PW[l]=PW[l-1]/2; PH[l]=PH[l-1]/2; float *a=fa((long)PW[l]*PH[l]),*b=fa((long)PW[l]*PH[l]);
        down2(P0[l-1],PW[l-1],PH[l-1],a); down2(P1[l-1],PW[l-1],PH[l-1],b); P0[l]=a;P1[l]=b; nl++; }
    float *u=fa(NN),*v=fa(NN),*nu=fa(NN),*nv=fa(NN),*su=fa(NN),*sv=fa(NN),*sw=fa(NN),*gx=fa(NN),*gy=fa(NN);
    int cw=PW[nl-1],chh=PH[nl-1]; fz(u,(long)cw*chh); fz(v,(long)cw*chh);
    for(int l=nl-1;l>=0;l--){ int W=PW[l],H=PH[l]; long n=(long)W*H; const float *a=P0[l],*b=P1[l];
        if(l!=nl-1){ for(int y=0;y<H;y++) for(int x=0;x<W;x++){
                float sx=x*0.5f-0.25f, sy=y*0.5f-0.25f; nu[(long)y*W+x]=2*bil(u,cw,chh,1,0,sx,sy,1); nv[(long)y*W+x]=2*bil(v,cw,chh,1,0,sx,sy,1); }
            for(long i=0;i<n;i++){ u[i]=nu[i]; v[i]=nv[i]; } cw=W; chh=H; }
        for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x;
            gx[i]=0.5f*(a[(long)y*W+clampi(x+1,0,W-1)]-a[(long)y*W+clampi(x-1,0,W-1)]);
            gy[i]=0.5f*(a[(long)clampi(y+1,0,H-1)*W+x]-a[(long)clampi(y-1,0,H-1)*W+x]); }
        fz(su,n); fz(sv,n); fz(sw,n);
        for(int py=0;;py+=ST){ if(py>H-PS) py=H-PS; for(int px=0;;px+=ST){ if(px>W-PS) px=W-PS;
            // template statistics and Hessian
            double h11=0,h12=0,h22=0, ma=0; for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++){ long i=(long)y*W+x; ma+=a[i]; double gxx=gx[i],gyy=gy[i]; h11+=gxx*gxx; h12+=gxx*gyy; h22+=gyy*gyy; }
            ma/=PS*PS; double gmx=0,gmy=0; for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++){ long i=(long)y*W+x; gmx+=gx[i]; gmy+=gy[i]; } gmx/=PS*PS; gmy/=PS*PS;
            // mean normalisation removes the patch mean, so the gradients do too
            h11-=PS*PS*gmx*gmx; h12-=PS*PS*gmx*gmy; h22-=PS*PS*gmy*gmy;
            double tr=h11+h22, det=h11*h22-h12*h12; double reg=1e-3*tr+1e-6; det=(h11+reg)*(h22+reg)-h12*h12;
            long ci=(long)(py+PS/2)*W+(px+PS/2); float u0=u[ci],v0=v[ci], pu=u0,pv=v0;
            if(det>1e-12){ for(int it=0;it<IT;it++){ double mb=0; for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++) mb+=bil(b,W,H,1,0,x+pu,y+pv,1); mb/=PS*PS;
                    double b1=0,b2=0; for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++){ long i=(long)y*W+x; double r=(bil(b,W,H,1,0,x+pu,y+pv,1)-mb)-(a[i]-ma); b1+=(gx[i]-gmx)*r; b2+=(gy[i]-gmy)*r; }
                    double du=((h22+reg)*b1-h12*b2)/det, dv=((h11+reg)*b2-h12*b1)/det; pu-=du; pv-=dv;
                    if(du*du+dv*dv<1e-4) break; }
                if((pu-u0)*(pu-u0)+(pv-v0)*(pv-v0)>PS*PS){ pu=u0; pv=v0; } }
            // densify: weight each pixel by how well this patch's motion explains it
            double mb=0; for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++) mb+=bil(b,W,H,1,0,x+pu,y+pv,1); mb/=PS*PS;
            for(int y=py;y<py+PS;y++) for(int x=px;x<px+PS;x++){ long i=(long)y*W+x; float r=(bil(b,W,H,1,0,x+pu,y+pv,1)-mb)-(a[i]-ma); r=r<0?-r:r; float wt=1.0f/(r>0.02f?r:0.02f);
                su[i]+=wt*pu; sv[i]+=wt*pv; sw[i]+=wt; }
            if(px==W-PS) break; }
          if(py==H-PS) break; }
        for(long i=0;i<n;i++) if(sw[i]>0){ u[i]=su[i]/sw[i]; v[i]=sv[i]/sw[i]; }
        // light smoothing in place of the variational refinement
        
        boxf(u,nu,W,H,1,1); boxf(v,nu,W,H,1,1);
        { float *t=fa(n*6); hsrefine(a,b,W,H,u,v,1e-2f,30,t,t+n,t+2*n,t+3*n,t+4*n,t+5*n); free(t); }
        // Outliers: hold the field within 24.0f px (level scale) of a robust affine fit over the face.
        { double pa[3],pb[3]; float *wt=su; for(long i=0;i<n;i++) wt[i]=wm?(WMs(wm,w,W,i)):1.0f;
          affine_fit(u,v,wt,W,H,2.0f,pa,pb); float cap=24.0f/(float)(1<<l); if(cap<2) cap=2;
          for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; float au=pa[0]+pa[1]*x+pa[2]*y, av=pb[0]+pb[1]*x+pb[2]*y;
              float ru=u[i]-au, rv=v[i]-av, r=__builtin_sqrtf(ru*ru+rv*rv); if(r>cap){ u[i]=au+ru*cap/r; v[i]=av+rv*cap/r; } } }
    }
    for(long i=0;i<NN;i++){ fx[i]=u[i]==u[i]?u[i]:0; fy[i]=v[i]==v[i]?v[i]:0; }
    for(int l=1;l<nl;l++){ free((void*)P0[l]); free((void*)P1[l]); }
    free(n0);free(n1);free(u);free(v);free(nu);free(nv);free(su);free(sv);free(sw);free(gx);free(gy);
}
static void fs_optical(const float *i0,const float *i1,const float *m2,const float *e2,const float *m1,int w,int h,float *out){
    long N=(long)w*h; float *g0=fa(N),*g1=fa(N),*fx=fa(N),*fy=fa(N);
    for(long i=0;i<N;i++){ g0[i]=0.114f*i0[3*i]+0.587f*i0[3*i+1]+0.299f*i0[3*i+2]; g1[i]=0.114f*i1[3*i]+0.587f*i1[3*i+1]+0.299f*i1[3*i+2]; }
    disflow(g0,g1,m1,w,h,fx,fy);
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
