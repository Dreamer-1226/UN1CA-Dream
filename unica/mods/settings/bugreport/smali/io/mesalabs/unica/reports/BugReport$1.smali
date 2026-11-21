.class Lio/mesalabs/unica/reports/BugReport$1;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Landroid/content/DialogInterface$OnDismissListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport;->start(Landroid/app/Activity;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$a:Landroid/app/Activity;

.field final synthetic val$started:[Z


# direct methods
.method constructor <init>([ZLandroid/app/Activity;)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 133
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$1;->val$started:[Z

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$1;->val$a:Landroid/app/Activity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onDismiss(Landroid/content/DialogInterface;)V
    .registers 3

    .line 136
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$1;->val$started:[Z

    const/4 v0, 0x0

    aget-boolean p1, p1, v0

    if-nez p1, :cond_c

    .line 137
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$1;->val$a:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->finish()V

    .line 139
    :cond_c
    return-void
.end method
