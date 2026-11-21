.class Lio/mesalabs/unica/reports/BugReport$3;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport;->run(Landroid/app/Activity;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$a:Landroid/app/Activity;

.field final synthetic val$app:Landroid/content/Context;

.field final synthetic val$note:Ljava/lang/String;

.field final synthetic val$wait:Landroid/app/AlertDialog;


# direct methods
.method constructor <init>(Landroid/content/Context;Ljava/lang/String;Landroid/app/AlertDialog;Landroid/app/Activity;)V
    .registers 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 152
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$app:Landroid/content/Context;

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$note:Ljava/lang/String;

    iput-object p3, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$wait:Landroid/app/AlertDialog;

    iput-object p4, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$a:Landroid/app/Activity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 11

    .line 158
    nop

    .line 160
    const/4 v0, 0x1

    const/4 v1, 0x0

    const/4 v2, 0x0

    :try_start_4
    iget-object v3, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$app:Landroid/content/Context;

    iget-object v4, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$note:Ljava/lang/String;

    invoke-static {v3, v4}, Lio/mesalabs/unica/reports/BugReport;->write(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    move-result-object v2

    .line 161
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v3

    const-string v4, "/storage/emulated/0/"

    const-string v5, ""

    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v3

    .line 162
    iget-object v4, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$app:Landroid/content/Context;

    const-string v5, "unica_bugreport_done"

    const-string v6, "Problem report saved.\n\n%1$s\n\nShare this file when you report the problem in the ROM maintainer. You can open the file to check its contents before sharing it."

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v7

    # invokes: Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    invoke-static {v4, v5, v6, v7}, Lio/mesalabs/unica/reports/BugReport;->access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4
    :try_end_26
    .catchall {:try_start_4 .. :try_end_26} :catchall_2f

    .line 167
    nop

    .line 175
    # setter for: Lio/mesalabs/unica/reports/BugReport;->sRunning:Z
    invoke-static {v1}, Lio/mesalabs/unica/reports/BugReport;->access$202(Z)Z

    .line 176
    move v7, v0

    move-object v8, v2

    move-object v9, v3

    move-object v6, v4

    goto :goto_56

    .line 168
    :catchall_2f
    move-exception v3

    .line 169
    :try_start_30
    const-string v4, "BugReport"

    const-string v5, "report failed"

    invoke-static {v4, v5, v3}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 170
    iget-object v4, p0, Lio/mesalabs/unica/reports/BugReport$3;->val$app:Landroid/content/Context;

    const-string v5, "unica_bugreport_failed"

    const-string v6, "Couldn\'t create problem report.\n\n%1$s"

    new-array v0, v0, [Ljava/lang/Object;

    .line 171
    invoke-virtual {v3}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    aput-object v3, v0, v1

    .line 170
    # invokes: Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    invoke-static {v4, v5, v6, v0}, Lio/mesalabs/unica/reports/BugReport;->access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3
    :try_end_4d
    .catchall {:try_start_30 .. :try_end_4d} :catchall_6e

    .line 172
    nop

    .line 173
    nop

    .line 175
    # setter for: Lio/mesalabs/unica/reports/BugReport;->sRunning:Z
    invoke-static {v1}, Lio/mesalabs/unica/reports/BugReport;->access$202(Z)Z

    .line 176
    move v7, v1

    move-object v8, v2

    move-object v6, v3

    move-object v9, v6

    .line 177
    :goto_56
    nop

    .line 178
    nop

    .line 179
    nop

    .line 180
    nop

    .line 181
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v1, Lio/mesalabs/unica/reports/BugReport$3$1;

    move-object v4, v1

    move-object v5, p0

    invoke-direct/range {v4 .. v9}, Lio/mesalabs/unica/reports/BugReport$3$1;-><init>(Lio/mesalabs/unica/reports/BugReport$3;Ljava/lang/String;ZLjava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 214
    return-void

    .line 175
    :catchall_6e
    move-exception v0

    # setter for: Lio/mesalabs/unica/reports/BugReport;->sRunning:Z
    invoke-static {v1}, Lio/mesalabs/unica/reports/BugReport;->access$202(Z)Z

    .line 176
    throw v0
.end method
