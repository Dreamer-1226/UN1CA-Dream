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
static void disflow(const float *g0,const float *g1,const float *wm,int w,int h,float *fx,float *fy,const double *SA,int lmin,float capfull){
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
    int cw=PW[nl-1],chh=PH[nl-1];
    // Global start: the two crops differ in scale (0.85-1.2) and position, far beyond what the patches
    // can find from zero. Search scale and shift exhaustively on the 1/8 level, over the base face only.
    if(SA){ float fc=(float)(1<<(nl-1));
      for(int y=0;y<chh;y++) for(int x=0;x<cw;x++){ float X=x*fc, Y=y*fc; u[(long)y*cw+x]=(float)((SA[0]*X+SA[1]*Y+SA[2]-X)/fc); v[(long)y*cw+x]=(float)((SA[3]*X+SA[4]*Y+SA[5]-Y)/fc); } }
    else { int sl=nl-1<3?nl-1:3, SW=PW[sl], SH=PH[sl]; const float *a=P0[sl],*b=P1[sl]; float f=(float)(1<<sl);
      float *mw=fa((long)SW*SH); for(int y=0;y<SH;y++) for(int x=0;x<SW;x++){ int X=x*(1<<sl), Y=y*(1<<sl); mw[(long)y*SW+x]=wm?(wm[(long)Y*w+X]>0.5f?1.0f:0.0f):1.0f; }
      double best=1e30; float bs=1,btx=0,bty=0; float cx=SW*0.5f, cy=SH*0.5f;
      for(int si=-10;si<=10;si++){ float sc=1.0f+0.025f*si;
          for(int ty=-14;ty<=14;ty++) for(int tx=-14;tx<=14;tx++){ double e=0,ws=0;
              for(int y=1;y<SH-1;y+=1) for(int x=1;x<SW-1;x+=1){ float wt=mw[(long)y*SW+x]; if(wt<=0) continue;
                  float qx=cx+sc*(x-cx)+tx, qy=cy+sc*(y-cy)+ty; if(qx<0||qy<0||qx>SW-1||qy>SH-1){ e+=wt*1.0; ws+=wt; continue; }
                  float d=bil(b,SW,SH,1,0,qx,qy,1)-a[(long)y*SW+x]; e+=wt*d*d; ws+=wt; }
              if(ws>0){ e/=ws; e*=1.0+0.002*(tx*tx+ty*ty)+0.5*(sc-1)*(sc-1); if(e<best){ best=e; bs=sc; btx=tx; bty=ty; } } } }
      free(mw);
      // as a flow field on the coarsest level: q = c + s (p - c) + t, in full-resolution pixels
      float fc=(float)(1<<(nl-1)); float CX=w*0.5f, CY=h*0.5f;
      for(int y=0;y<chh;y++) for(int x=0;x<cw;x++){ float X=x*fc, Y=y*fc;
          u[(long)y*cw+x]=((CX+bs*(X-CX)+btx*f)-X)/fc; v[(long)y*cw+x]=((CY+bs*(Y-CY)+bty*f)-Y)/fc; } }
    for(int l=nl-1;l>=0;l--){ int W=PW[l],H=PH[l]; long n=(long)W*H; const float *a=P0[l],*b=P1[l];
        if(l!=nl-1){ for(int y=0;y<H;y++) for(int x=0;x<W;x++){
                float sx=x*0.5f-0.25f, sy=y*0.5f-0.25f; nu[(long)y*W+x]=2*bil(u,cw,chh,1,0,sx,sy,1); nv[(long)y*W+x]=2*bil(v,cw,chh,1,0,sx,sy,1); }
            for(long i=0;i<n;i++){ u[i]=nu[i]; v[i]=nv[i]; } cw=W; chh=H; }
        if(l<lmin) continue;
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
        if(SA){ // hold the field near the eye-anchored similarity
          float sc=(float)(1<<l), cap=capfull/sc; if(cap<1) cap=1;
          for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; float X=x*sc, Y=y*sc;
              float au=(float)((SA[0]*X+SA[1]*Y+SA[2]-X)/sc), av=(float)((SA[3]*X+SA[4]*Y+SA[5]-Y)/sc);
              float ru=u[i]-au, rv=v[i]-av, r=__builtin_sqrtf(ru*ru+rv*rv); if(r>cap){ u[i]=au+ru*cap/r; v[i]=av+rv*cap/r; } } }
        else { double pa[3],pb[3]; float *wt=su; for(long i=0;i<n;i++) wt[i]=wm?(WMs(wm,w,W,i)):1.0f;
          affine_fit(u,v,wt,W,H,2.0f,pa,pb); float cap=48.0f/(float)(1<<l); if(cap<2) cap=2;
          for(int y=0;y<H;y++) for(int x=0;x<W;x++){ long i=(long)y*W+x; float au=pa[0]+pa[1]*x+pa[2]*y, av=pb[0]+pb[1]*x+pb[2]*y;
              float ru=u[i]-au, rv=v[i]-av, r=__builtin_sqrtf(ru*ru+rv*rv); if(r>cap){ u[i]=au+ru*cap/r; v[i]=av+rv*cap/r; } } }
    }
    for(long i=0;i<NN;i++){ fx[i]=u[i]==u[i]?u[i]:0; fy[i]=v[i]==v[i]?v[i]:0; }
    for(int l=1;l<nl;l++){ free((void*)P0[l]); free((void*)P1[l]); }
    free(n0);free(n1);free(u);free(v);free(nu);free(nv);free(su);free(sv);free(sw);free(gx);free(gy);
}
static void unfold(float *u,float *v,int w,int h){
    long NN=(long)w*h; float *sw=fa(NN),*su=fa(NN),*sv=fa(NN),*nu=fa(NN);
    // Unfold: where the warp folds over itself (Jacobian determinant of p+f(p) below 0.5) one candidate
    // feature gets copied twice and smeared, as on the lips and the neck. Relax the flow there toward its
    // local average until the map is close to one-to-one.
    for(int pass=0;pass<8;pass++){ long bad=0;
        for(int y=0;y<h;y++) for(int x=0;x<w;x++){ long i=(long)y*w+x; int xl=clampi(x-1,0,w-1),xr=clampi(x+1,0,w-1),yu=clampi(y-1,0,h-1),yd=clampi(y+1,0,h-1);
            float ux=(u[(long)y*w+xr]-u[(long)y*w+xl])/(xr-xl?xr-xl:1), uy=(u[(long)yd*w+x]-u[(long)yu*w+x])/(yd-yu?yd-yu:1);
            float vx=(v[(long)y*w+xr]-v[(long)y*w+xl])/(xr-xl?xr-xl:1), vy=(v[(long)yd*w+x]-v[(long)yu*w+x])/(yd-yu?yd-yu:1);
            float det=(1+ux)*(1+vy)-uy*vx; float t=(det-0.3f)/0.4f; t=t<0?0:(t>1?1:t); sw[i]=1-t; if(t<1) bad++; }
        if(bad==0) break;
        boxf(sw,nu,w,h,3,1);
        for(long i=0;i<NN;i++){ su[i]=u[i]; sv[i]=v[i]; }
        boxf(su,nu,w,h,6,2); boxf(sv,nu,w,h,6,2);
        for(long i=0;i<NN;i++){ float k=sw[i]; if(k>1)k=1; u[i]+=k*(su[i]-u[i]); v[i]+=k*(sv[i]-v[i]); } }
    free(sw);free(su);free(sv);free(nu); }
// Head pose differs between burst frames (tilt, distance), and a dense matcher started from a plain
// shift locks eyes onto brows and mouths onto chins. The eyes are the one region both frames reliably
// share, and the candidate's eye mask tells us where they are: search a similarity transform (scale,
// rotation, position) that maps the candidate's eye band onto the base by normalised cross-correlation,
// coarse on a quarter-resolution grid, then refined at full resolution. SA: base -> candidate, 2x3.
static void down4(const float *s,int w,int h,float *d){ int W=w/4,H=h/4; for(int y=0;y<H;y++) for(int x=0;x<W;x++){ float a=0; for(int j=0;j<4;j++) for(int i=0;i<4;i++) a+=s[(long)(4*y+j)*w+4*x+i]; d[(long)y*W+x]=a/16; } }
// small angles only (|x| < 0.3): no libm in this library
static float ssin(float x){ float x2=x*x; return x*(1-x2/6*(1-x2/20*(1-x2/42))); }
static float scos(float x){ float x2=x*x; return 1-x2/2*(1-x2/12*(1-x2/30)); }
static float ncc_at(const float *g0,const float *g1,int w,int h,int sc,int stp,float hw,float hh,float cx,float cy,float s,float th,float bx,float by){
    // all coordinates in full-resolution pixels; images at 1/sc resolution
    float cs=scos(th)*s, sn=ssin(th)*s; double sa=0,sb=0,saa=0,sbb=0,sab=0; int n=0; int W=w/sc,H=h/sc;
    for(float dy=-hh;dy<=hh;dy+=stp) for(float dx=-hw;dx<=hw;dx+=stp){
        float px=bx+dx, py=by+dy, qx=cx+cs*dx-sn*dy, qy=cy+sn*dx+cs*dy;
        if(px<0||py<0||px>w-1||py>h-1||qx<0||qy<0||qx>w-1||qy>h-1) continue;
        double a=bil(g0,W,H,1,0,px/sc,py/sc,1), b=bil(g1,W,H,1,0,qx/sc,qy/sc,1); sa+=a; sb+=b; saa+=a*a; sbb+=b*b; sab+=a*b; n++; }
    if(n<24) return -2; double ma=sa/n, mb=sb/n, va=saa/n-ma*ma, vb=sbb/n-mb*mb; if(va<1e-9||vb<1e-9) return -2;
    return (float)((sab/n-ma*mb)/__builtin_sqrt(va*vb)); }
static int eye_similarity(const float *g0,const float *g1,const float *e2,int w,int h,double *SA){
    long N=(long)w*h; int x0=w,y0=h,x1=-1,y1=-1; long cnt=0;
    for(int y=0;y<h;y++) for(int x=0;x<w;x++) if(e2[(long)y*w+x]>0.5f){ cnt++; if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; }
    if(cnt<60 || x1-x0<24) return 0;
    float cx=0.5f*(x0+x1), cy=0.5f*(y0+y1), hw=0.5f*(x1-x0)+22, hh=0.5f*(y1-y0)+28;
    float *q0=fa(N/16),*q1=fa(N/16),*o0=fa(N/64),*o1=fa(N/64); down4(g0,w,h,q0); down4(g1,w,h,q1); down2(q0,w/4,h/4,o0); down2(q1,w/4,h/4,o1);
    float best=-2,bs=1,bt=0,bx=cx,by=cy; const float D=0.01745329f;
    // 1/8 resolution: scale 0.75-1.35, rotation +-12 deg, position +-80 px
    for(int si=0;si<=12;si++){ float s=0.75f+0.05f*si; for(int ti=-4;ti<=4;ti++){ float th=ti*3*D;
        for(int dy=-80;dy<=80;dy+=8) for(int dx=-80;dx<=80;dx+=8){ float c=ncc_at(o0,o1,w,h,8,8,hw,hh,cx,cy,s,th,cx+dx,cy+dy); if(c>best){ best=c; bs=s; bt=th; bx=cx+dx; by=cy+dy; } } } }
    // 1/4 resolution around it
    { float s0=bs,t0=bt,x0b=bx,y0b=by; best=-2;
      for(int si=-2;si<=2;si++) for(int ti=-2;ti<=2;ti++) for(int dy=-8;dy<=8;dy+=4) for(int dx=-8;dx<=8;dx+=4){ float s=s0+0.025f*si, th=t0+1.5f*D*ti;
          float c=ncc_at(q0,q1,w,h,4,4,hw,hh,cx,cy,s,th,x0b+dx,y0b+dy); if(c>best){ best=c; bs=s; bt=th; bx=x0b+dx; by=y0b+dy; } } }
    free(q0); free(q1); free(o0); free(o1);
    // refine at full resolution (sampled every 2 px), shrinking steps
    float st_s=0.0125f, st_t=0.75f*D, st_p=2.0f; best=ncc_at(g0,g1,w,h,1,2,hw,hh,cx,cy,bs,bt,bx,by);
    for(int r=0;r<3;r++){ int moved=1; while(moved){ moved=0; float cs=bs,ct=bt,cxx=bx,cyy=by;
        for(int a=-1;a<=1;a++) for(int b=-1;b<=1;b++) for(int c=-1;c<=1;c++) for(int d=-1;d<=1;d++){
            float c2=ncc_at(g0,g1,w,h,1,2,hw,hh,cx,cy,cs+a*st_s,ct+b*st_t,cxx+c*st_p,cyy+d*st_p); if(c2>best+1e-5f){ best=c2; bs=cs+a*st_s; bt=ct+b*st_t; bx=cxx+c*st_p; by=cyy+d*st_p; moved=1; } } }
        st_s*=0.5f; st_t*=0.5f; st_p*=0.5f; }
    if(best<0.5f) return 0;
    double cs=scos(bt)*bs, sn=ssin(bt)*bs;
    SA[0]=cs; SA[1]=-sn; SA[2]=cx-cs*bx+sn*by; SA[3]=sn; SA[4]=cs; SA[5]=cy-sn*bx-cs*by;
#ifdef BF_TEST
    fprintf(stderr,"eye sim ncc %.3f s %.3f th %.2f base (%.1f,%.1f) cand (%.1f,%.1f)\n",best,bs,bt/D,bx,by,cx,cy);
#endif
    return 1; }
static void fs_optical(const float *i0,const float *i1,const float *m2,const float *e2,const float *m1,int w,int h,float *out){
    long N=(long)w*h; float *g0=fa(N),*g1=fa(N),*fx=fa(N),*fy=fa(N);
    for(long i=0;i<N;i++){ g0[i]=0.114f*i0[3*i]+0.587f*i0[3*i+1]+0.299f*i0[3*i+2]; g1[i]=0.114f*i1[3*i]+0.587f*i1[3*i+1]+0.299f*i1[3*i+2]; }
    double SA[6]; int ok=eye_similarity(g0,g1,e2,w,h,SA);
    if(ok){ // a rigid placement keeps the candidate's own expression intact; Fusion blends the seam
        for(int y=0;y<h;y++) for(int x=0;x<w;x++){ long i=(long)y*w+x; fx[i]=(float)(SA[0]*x+SA[1]*y+SA[2]-x); fy[i]=(float)(SA[3]*x+SA[4]*y+SA[5]-y); } }
    else { disflow(g0,g1,m1,w,h,fx,fy,0,0,0); unfold(fx,fy,w,h); }
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
        // The seam often crosses structure that differs between the frames (bangs over a brow, a cheek
        // against the background), and a plain membrane carries those differences far into the face:
        // a washed-out eye under a fringe. Use only the colour shift: clamp boundary differences to a
        // narrow band around their median along the seam.
        float med=0; { int hist[256]={0}; long nb=0;
            for(long i=0;i<N;i++) if(e[i]<=0 && m[i]>0.5f){ float d=in[8*i+c]-w2[3*i+c]; int b=(int)((d+0.5f)*255); b=b<0?0:(b>255?255:b); hist[b]++; nb++; }
            long acc=0; for(int b=0;b<256;b++){ acc+=hist[b]; if(acc*2>=nb){ med=b/255.0f-0.5f; break; } } }
        for(long i=0;i<N;i++){ float d=in[8*i+c]-w2[3*i+c]; if(d>med+0.04f) d=med+0.04f; if(d<med-0.04f) d=med-0.04f; cc[i]=d*wo[i]; }
        boxf(cc,T,w,h,12,3);
        for(long i=0;i<N;i++){ float d=in[8*i+c]-w2[3*i+c]; if(d>med+0.04f) d=med+0.04f; if(d<med-0.04f) d=med-0.04f; cc[i]= e[i]>0 ? cc[i]/(ow[i]+1e-6f) : d; }
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
