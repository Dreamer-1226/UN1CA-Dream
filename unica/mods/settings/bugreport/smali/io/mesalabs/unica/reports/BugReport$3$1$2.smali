.class Lio/mesalabs/unica/reports/BugReport$3$1$2;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


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

    .line 201
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3$1$2;->this$1:Lio/mesalabs/unica/reports/BugReport$3$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .registers 3

    .line 204
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3$1$2;->this$1:Lio/mesalabs/unica/reports/BugReport$3$1;

    iget-object p1, p1, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object p1, p1, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    iget-object p2, p0, Lio/mesalabs/unica/reports/BugReport$3$1$2;->this$1:Lio/mesalabs/unica/reports/BugReport$3$1;

    iget-object p2, p2, Lio/mesalabs/unica/reports/BugReport$3$1;->val$report:Ljava/io/File;

    # invokes: Lio/mesalabs/unica/reports/BugReport;->share(Landroid/app/Activity;Ljava/io/File;)V
    invoke-static {p1, p2}, Lio/mesalabs/unica/reports/BugReport;->access$300(Landroid/app/Activity;Ljava/io/File;)V

    .line 205
    return-void
.end method
