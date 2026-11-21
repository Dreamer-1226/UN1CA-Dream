.class Lio/mesalabs/unica/reports/BugReport$3$1;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport$3;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lio/mesalabs/unica/reports/BugReport$3;

.field final synthetic val$b:Ljava/lang/String;

.field final synthetic val$done:Z

.field final synthetic val$m:Ljava/lang/String;

.field final synthetic val$report:Ljava/io/File;


# direct methods
.method constructor <init>(Lio/mesalabs/unica/reports/BugReport$3;Ljava/lang/String;ZLjava/io/File;Ljava/lang/String;)V
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 181
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$m:Ljava/lang/String;

    iput-boolean p3, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$done:Z

    iput-object p4, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$report:Ljava/io/File;

    iput-object p5, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$b:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 6

    .line 185
    :try_start_0
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$3;->val$wait:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->dismiss()V
    :try_end_7
    .catchall {:try_start_0 .. :try_end_7} :catchall_8

    .line 188
    goto :goto_9

    .line 186
    :catchall_8
    move-exception v0

    .line 189
    :goto_9
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->isFinishing()Z

    move-result v0

    if-nez v0, :cond_60

    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->isDestroyed()Z

    move-result v0

    if-nez v0, :cond_60

    .line 190
    new-instance v0, Landroid/app/AlertDialog$Builder;

    iget-object v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v1, v1, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$m:Ljava/lang/String;

    .line 191
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 192
    const v1, 0x104000a

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lio/mesalabs/unica/reports/BugReport$3$1$1;

    invoke-direct {v1, p0}, Lio/mesalabs/unica/reports/BugReport$3$1$1;-><init>(Lio/mesalabs/unica/reports/BugReport$3$1;)V

    .line 193
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 199
    iget-boolean v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$done:Z

    if-eqz v1, :cond_5c

    iget-object v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$report:Ljava/io/File;

    if-eqz v1, :cond_5c

    .line 200
    iget-object v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v1, v1, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    const/4 v2, 0x0

    new-array v2, v2, [Ljava/lang/Object;

    const-string v3, "unica_bugreport_share"

    const-string v4, "Share"

    # invokes: Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    invoke-static {v1, v3, v4, v2}, Lio/mesalabs/unica/reports/BugReport;->access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lio/mesalabs/unica/reports/BugReport$3$1$2;

    invoke-direct {v2, p0}, Lio/mesalabs/unica/reports/BugReport$3$1$2;-><init>(Lio/mesalabs/unica/reports/BugReport$3$1;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNeutralButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 208
    :cond_5c
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 209
    goto :goto_6f

    .line 210
    :cond_60
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->this$0:Lio/mesalabs/unica/reports/BugReport$3;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$3;->val$app:Landroid/content/Context;

    iget-object v1, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$b:Ljava/lang/String;

    iget-boolean v2, p0, Lio/mesalabs/unica/reports/BugReport$3$1;->val$done:Z

    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 212
    :goto_6f
    return-void
.end method
