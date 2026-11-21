.class Lio/mesalabs/unica/reports/BugReport$3$1$1;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Landroid/content/DialogInterface$OnDismissListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport$3$1;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lio/mesalabs/unica/reports/BugReport$3$1;


# direct methods
.method constructor <init>(Lio/mesalabs/unica/reports/BugReport$3$1;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 193
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3$1$1;->this$1:Lio/mesalabs/unica/reports/BugReport$3$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onDismiss(Landroid/content/DialogInterface;)V
    .registers 2

    .line 196
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3$1$1;->this$1:Lio/mesalabs/unica/reports/BugReport$3$1;

    iget-object p1, p1, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object p1, p1, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->finish()V

    .line 197
    return-void
.end method
