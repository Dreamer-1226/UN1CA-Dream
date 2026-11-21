.class Lio/mesalabs/unica/reports/BugReport$2;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


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

.field final synthetic val$note:Landroid/widget/EditText;

.field final synthetic val$started:[Z


# direct methods
.method constructor <init>([ZLandroid/app/Activity;Landroid/widget/EditText;)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 125
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$started:[Z

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$a:Landroid/app/Activity;

    iput-object p3, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$note:Landroid/widget/EditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .registers 4

    .line 128
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$started:[Z

    const/4 p2, 0x0

    const/4 v0, 0x1

    aput-boolean v0, p1, p2

    .line 129
    iget-object p1, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$a:Landroid/app/Activity;

    iget-object p2, p0, Lio/mesalabs/unica/reports/BugReport$2;->val$note:Landroid/widget/EditText;

    invoke-virtual {p2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object p2

    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p2

    # invokes: Lio/mesalabs/unica/reports/BugReport;->run(Landroid/app/Activity;Ljava/lang/String;)V
    invoke-static {p1, p2}, Lio/mesalabs/unica/reports/BugReport;->access$000(Landroid/app/Activity;Ljava/lang/String;)V

    .line 130
    return-void
.end method
