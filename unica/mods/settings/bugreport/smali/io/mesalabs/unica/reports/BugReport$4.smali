.class Lio/mesalabs/unica/reports/BugReport$4;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Landroid/media/MediaScannerConnection$OnScanCompletedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport;->share(Landroid/app/Activity;Ljava/io/File;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$a:Landroid/app/Activity;

.field final synthetic val$app:Landroid/content/Context;


# direct methods
.method constructor <init>(Landroid/content/Context;Landroid/app/Activity;)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 253
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$4;->val$a:Landroid/app/Activity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onScanCompleted(Ljava/lang/String;Landroid/net/Uri;)V
    .registers 4

    .line 256
    new-instance p1, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {p1, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v0, Lio/mesalabs/unica/reports/BugReport$4$1;

    invoke-direct {v0, p0, p2}, Lio/mesalabs/unica/reports/BugReport$4$1;-><init>(Lio/mesalabs/unica/reports/BugReport$4;Landroid/net/Uri;)V

    invoke-virtual {p1, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 287
    return-void
.end method
