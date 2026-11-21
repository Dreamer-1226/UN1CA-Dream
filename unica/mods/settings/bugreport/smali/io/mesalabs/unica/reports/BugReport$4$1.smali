.class Lio/mesalabs/unica/reports/BugReport$4$1;
.super Ljava/lang/Object;
.source "BugReport.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/BugReport$4;->onScanCompleted(Ljava/lang/String;Landroid/net/Uri;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lio/mesalabs/unica/reports/BugReport$4;

.field final synthetic val$uri:Landroid/net/Uri;


# direct methods
.method constructor <init>(Lio/mesalabs/unica/reports/BugReport$4;Landroid/net/Uri;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 256
    iput-object p1, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iput-object p2, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->val$uri:Landroid/net/Uri;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 8

    .line 259
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->val$uri:Landroid/net/Uri;

    const/4 v1, 0x0

    const-string v2, "Couldn\'t share the file. It\'s saved in the UN1CA/reports folder."

    const-string v3, "unica_bugreport_share_failed"

    const/4 v4, 0x1

    if-nez v0, :cond_20

    .line 260
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    new-array v1, v1, [Ljava/lang/Object;

    # invokes: Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    invoke-static {v5, v3, v2, v1}, Lio/mesalabs/unica/reports/BugReport;->access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1, v4}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    .line 262
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 263
    return-void

    .line 266
    :cond_20
    :try_start_20
    new-instance v0, Landroid/content/Intent;

    const-string v5, "android.intent.action.SEND"

    invoke-direct {v0, v5}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    const-string v5, "application/zip"

    .line 267
    invoke-virtual {v0, v5}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    const-string v5, "android.intent.extra.STREAM"

    iget-object v6, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->val$uri:Landroid/net/Uri;

    .line 268
    invoke-virtual {v0, v5, v6}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    move-result-object v0

    const-string v5, "android.intent.extra.SUBJECT"

    const-string v6, "UN1CA problem report"

    .line 269
    invoke-virtual {v0, v5, v6}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    .line 270
    invoke-virtual {v0, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    move-result-object v0

    .line 271
    const-string v5, ""

    iget-object v6, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->val$uri:Landroid/net/Uri;

    invoke-static {v5, v6}, Landroid/content/ClipData;->newRawUri(Ljava/lang/CharSequence;Landroid/net/Uri;)Landroid/content/ClipData;

    move-result-object v5

    invoke-virtual {v0, v5}, Landroid/content/Intent;->setClipData(Landroid/content/ClipData;)V

    .line 272
    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    invoke-static {v5}, Lio/mesalabs/unica/reports/BugReport;->title(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;

    move-result-object v0

    .line 273
    invoke-virtual {v0, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    move-result-object v0

    .line 274
    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$a:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->isFinishing()Z

    move-result v5

    if-nez v5, :cond_78

    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$a:Landroid/app/Activity;

    invoke-virtual {v5}, Landroid/app/Activity;->isDestroyed()Z

    move-result v5

    if-nez v5, :cond_78

    .line 275
    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$a:Landroid/app/Activity;

    invoke-virtual {v5, v0}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    goto :goto_85

    .line 277
    :cond_78
    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    const/high16 v6, 0x10000000

    invoke-virtual {v0, v6}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    move-result-object v0

    invoke-virtual {v5, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    :try_end_85
    .catchall {:try_start_20 .. :try_end_85} :catchall_86

    .line 284
    :goto_85
    goto :goto_a3

    .line 279
    :catchall_86
    move-exception v0

    .line 280
    const-string v5, "BugReport"

    const-string v6, "share failed"

    invoke-static {v5, v6, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 281
    iget-object v0, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v0, v0, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    iget-object v5, p0, Lio/mesalabs/unica/reports/BugReport$4$1;->this$0:Lio/mesalabs/unica/reports/BugReport$4;

    iget-object v5, v5, Lio/mesalabs/unica/reports/BugReport$4;->val$app:Landroid/content/Context;

    new-array v1, v1, [Ljava/lang/Object;

    # invokes: Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    invoke-static {v5, v3, v2, v1}, Lio/mesalabs/unica/reports/BugReport;->access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1, v4}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    .line 283
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 285
    :goto_a3
    return-void
.end method
