.class Lio/mesalabs/unica/reports/Scrub$1;
.super Ljava/lang/Object;
.source "Scrub.java"

# interfaces
.implements Ljava/util/Comparator;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/Comparator<",
        "[",
        "Ljava/lang/String;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic this$0:Lio/mesalabs/unica/reports/Scrub;


# direct methods
.method constructor <init>(Lio/mesalabs/unica/reports/Scrub;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 117
    iput-object p1, p0, Lio/mesalabs/unica/reports/Scrub$1;->this$0:Lio/mesalabs/unica/reports/Scrub;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public bridge synthetic compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000
        }
        names = {
            null,
            null
        }
    .end annotation

    .line 117
    check-cast p1, [Ljava/lang/String;

    check-cast p2, [Ljava/lang/String;

    invoke-virtual {p0, p1, p2}, Lio/mesalabs/unica/reports/Scrub$1;->compare([Ljava/lang/String;[Ljava/lang/String;)I

    move-result p1

    return p1
.end method

.method public compare([Ljava/lang/String;[Ljava/lang/String;)I
    .registers 4

    .line 120
    const/4 v0, 0x0

    aget-object p2, p2, v0

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result p2

    aget-object p1, p1, v0

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result p1

    sub-int/2addr p2, p1

    return p2
.end method
