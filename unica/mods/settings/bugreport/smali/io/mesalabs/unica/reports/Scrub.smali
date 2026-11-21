.class final Lio/mesalabs/unica/reports/Scrub;
.super Ljava/lang/Object;
.source "Scrub.java"


# static fields
.field private static final DIGITS15:Ljava/util/regex/Pattern;

.field private static final EMAIL:Ljava/util/regex/Pattern;

.field private static final HARDWARE_ID:Ljava/util/regex/Pattern;

.field private static final HOST:Ljava/util/regex/Pattern;

.field private static final ICCID:Ljava/util/regex/Pattern;

.field private static final IPV4:Ljava/util/regex/Pattern;

.field private static final IPV6:Ljava/util/regex/Pattern;

.field private static final KERNEL_ID:Ljava/util/regex/Pattern;

.field private static final LATLON:Ljava/util/regex/Pattern;

.field private static final LOCATION:Ljava/util/regex/Pattern;

.field private static final MAC:Ljava/util/regex/Pattern;

.field private static final PHONE:Ljava/util/regex/Pattern;

.field private static final POSSESSIVE:Ljava/util/regex/Pattern;

.field private static final SAMSUNG_SERIAL:Ljava/util/regex/Pattern;

.field private static final SAMSUNG_WIFI:Ljava/util/regex/Pattern;

.field private static final SSID:Ljava/util/regex/Pattern;

.field private static final SSID_HEX:Ljava/util/regex/Pattern;

.field private static final SUBSCRIBER:Ljava/util/regex/Pattern;

.field private static final TOKEN:Ljava/util/regex/Pattern;

.field private static final VERSION_BEFORE:Ljava/util/regex/Pattern;


# instance fields
.field final counts:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private final known:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "[",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private final names:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/util/regex/Pattern;",
            ">;"
        }
    .end annotation
.end field

.field private final next:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private final tags:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 45
    const-string v0, "(?<![\\w.+%-])[\\w.+%-]*[A-Za-z][\\w.+%-]*@(?!(?:com|org|net|android|androidx|vendor)\\.)(?:[A-Za-z0-9-]+\\.)+(?i:com|net|org|edu|gov|mil|info|biz|io|co|me|app|dev|ai|(?!so|rc|ko|sh|py|js|gz|xz|bp|mk|pb|db)[a-z]{2})(?![\\w-]|\\.[A-Za-z0-9])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->EMAIL:Ljava/util/regex/Pattern;

    .line 50
    const-string v0, "(?<![\\w.-])[A-Za-z0-9][A-Za-z0-9-]*\\.local(?![\\w-]|\\.[A-Za-z0-9])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->HOST:Ljava/util/regex/Pattern;

    .line 52
    const-string v0, "(?<![0-9A-Fa-f:-])(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}(?![0-9A-Fa-f:-])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->MAC:Ljava/util/regex/Pattern;

    .line 54
    const-string v0, "(?<![\\w+])(?:\\+\\d{1,3}[ -]?\\d{1,4}[ -]?\\d{3,4}[ -]?\\d{4}|01[016789][ -]?\\d{3,4}[ -]?\\d{4})(?!\\d)"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->PHONE:Ljava/util/regex/Pattern;

    .line 57
    const-string v0, "(?:(?<![A-Za-z])|(?<=[a-z])(?=[A-Z]))(?i:(imei|imsi|iccid|meid|msisdn|subscriberid|line1number|phonenumber))([^0-9\\n]{0,20}?)(\\d{6,20})"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->SUBSCRIBER:Ljava/util/regex/Pattern;

    .line 61
    const-string v0, "(?<![\\w.])\\d{15}(?![\\w.])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->DIGITS15:Ljava/util/regex/Pattern;

    .line 62
    const-string v0, "(?<!\\d)89\\d{17,18}(?!\\d)"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->ICCID:Ljava/util/regex/Pattern;

    .line 63
    const-string v0, "(?i)(\\bssid\\b\"?\\s*[:=]\\s*\"?)([^\"\',\\]\\s<][^\"\',\\]]{0,31}?)(?=[\"\',\\]]|\\s{2}|$)"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->SSID:Ljava/util/regex/Pattern;

    .line 66
    const-string v0, "(?i)(\\bssid\\b\"?\\s*[:=]\\s*\"?)([0-9a-f]{8,64})(?![0-9a-f])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->SSID_HEX:Ljava/util/regex/Pattern;

    .line 72
    const-string v0, "\"([^\"<>]{1,32})\"(?=-?(?:WPA_PSK|SAE|NONE|OWE|WEP|WPA_EAP|IEEE8021X|SUITE_B_192|WAPI_PSK|WAPI_CERT|DPP)\\b)"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->SAMSUNG_WIFI:Ljava/util/regex/Pattern;

    .line 75
    const-string v0, "(?i)\\b((?:get_?)?(?:own_?)?(?:device_?id|android_?id|gsf_?id|ssaid|guid))\\b[^\\w\\n]{0,4}([0-9a-f-]{16,})"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->HARDWARE_ID:Ljava/util/regex/Pattern;

    .line 83
    const-string v0, "(?:^|(?<=[\\s\"\'=:(\\[,>]))([^\\s\"\'<>=:(\\[,]{1,20}?)(?=(?:\uc758|\'s)[\\s_-]+(?:Galaxy|Buds|Watch|Tab|Book|S Pen|Z ?Fold|Z ?Flip|Fold|Flip|Ring|Note|[SAM]\\d{1,2}\\b|PC|TV|Phone|Laptop|iPhone|iPad|AirPods|MacBook|\uac24\ub7ed\uc2dc|\ub178\ud2b8\ubd81|\ud734\ub300\ud3f0|\ud3f0|\ud0dc\ube14\ub9bf|\ud0ed|\uc6cc\uce58|\ubc84\uc988))"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->POSSESSIVE:Ljava/util/regex/Pattern;

    .line 86
    const-string v0, "(?i)(?:\\w\\[|\\bv|version:?\\s*[a-z]{0,3})$"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->VERSION_BEFORE:Ljava/util/regex/Pattern;

    .line 87
    const-string v0, "(Location\\[\\w+\\s+)(-?\\d{1,3}\\.\\d{3,}),(-?\\d{1,3}\\.\\d{3,})"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->LOCATION:Ljava/util/regex/Pattern;

    .line 89
    const-string v0, "(?i)\\b(lat|latitude|lon|lng|longitude)(\\s*[=:]\\s*)(-?\\d{1,3}\\.\\d{3,})"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->LATLON:Ljava/util/regex/Pattern;

    .line 91
    const-string v0, "(?<![\\d.])(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})(?![\\d.])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->IPV4:Ljava/util/regex/Pattern;

    .line 93
    const-string v0, "(?<![\\w:])2[0-9a-fA-F]{3}(?::[0-9a-fA-F]{0,4}){3,7}(?![\\w:])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->IPV6:Ljava/util/regex/Pattern;

    .line 95
    const-string v0, "(?<![\\w-])[A-Za-z0-9_-]{120,}(?![\\w-])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->TOKEN:Ljava/util/regex/Pattern;

    .line 96
    const-string v0, "(?<![A-Z0-9])R[0-9][0-9A-Z]{9}(?![A-Z0-9])"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->SAMSUNG_SERIAL:Ljava/util/regex/Pattern;

    .line 101
    const-string v0, "(?i)(androidboot\\.(?:serialno|ap_serial|em\\.did|un|prototype_serial)=|\\b(?:serialno|ap_serial)\\s*[=:]\\s*)(0x[0-9a-f]{6,}|[0-9a-z]{6,})"

    invoke-static {v0}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/Scrub;->KERNEL_ID:Ljava/util/regex/Pattern;

    return-void
.end method

.method constructor <init>()V
    .registers 2

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 32
    new-instance v0, Ljava/util/TreeMap;

    invoke-direct {v0}, Ljava/util/TreeMap;-><init>()V

    iput-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->counts:Ljava/util/Map;

    .line 34
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->known:Ljava/util/List;

    .line 35
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->names:Ljava/util/Map;

    .line 36
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->tags:Ljava/util/Map;

    .line 37
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->next:Ljava/util/Map;

    return-void
.end method

.method static decodePercent(Ljava/lang/String;)Ljava/lang/String;
    .registers 10

    .line 150
    nop

    .line 151
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    .line 152
    const/4 v1, 0x0

    const/4 v2, 0x0

    move v3, v2

    :goto_8
    if-ge v3, v0, :cond_53

    .line 153
    invoke-virtual {p0, v3}, Ljava/lang/String;->charAt(I)C

    move-result v4

    .line 154
    const/16 v5, 0x25

    if-ne v4, v5, :cond_4b

    add-int/lit8 v5, v3, 0x2

    if-ge v5, v0, :cond_4b

    .line 155
    add-int/lit8 v6, v3, 0x1

    invoke-virtual {p0, v6}, Ljava/lang/String;->charAt(I)C

    move-result v6

    const/16 v7, 0x10

    invoke-static {v6, v7}, Ljava/lang/Character;->digit(CI)I

    move-result v6

    .line 156
    invoke-virtual {p0, v5}, Ljava/lang/String;->charAt(I)C

    move-result v8

    invoke-static {v8, v7}, Ljava/lang/Character;->digit(CI)I

    move-result v7

    .line 157
    mul-int/lit8 v8, v6, 0x10

    add-int/2addr v8, v7

    .line 158
    if-ltz v6, :cond_4b

    if-ltz v7, :cond_4b

    const/16 v6, 0x20

    if-lt v8, v6, :cond_4b

    const/16 v6, 0x7f

    if-ge v8, v6, :cond_4b

    .line 159
    if-nez v1, :cond_44

    .line 160
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v0}, Ljava/lang/StringBuilder;-><init>(I)V

    invoke-virtual {v1, p0, v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/CharSequence;II)Ljava/lang/StringBuilder;

    move-result-object v1

    .line 162
    :cond_44
    int-to-char v3, v8

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 163
    nop

    .line 164
    move v3, v5

    goto :goto_50

    .line 167
    :cond_4b
    if-eqz v1, :cond_50

    .line 168
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 152
    :cond_50
    :goto_50
    add-int/lit8 v3, v3, 0x1

    goto :goto_8

    .line 171
    :cond_53
    if-nez v1, :cond_56

    goto :goto_5a

    :cond_56
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    :goto_5a
    return-object p0
.end method

.method static luhn(Ljava/lang/String;)Z
    .registers 8

    .line 360
    nop

    .line 361
    nop

    .line 362
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x1

    sub-int/2addr v0, v1

    const/4 v2, 0x0

    move v3, v2

    move v4, v3

    :goto_b
    if-ltz v0, :cond_24

    .line 363
    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v5

    add-int/lit8 v5, v5, -0x30

    .line 364
    if-eqz v4, :cond_1d

    .line 365
    mul-int/lit8 v5, v5, 0x2

    .line 366
    const/16 v6, 0x9

    if-le v5, v6, :cond_1d

    .line 367
    add-int/lit8 v5, v5, -0x9

    .line 370
    :cond_1d
    add-int/2addr v3, v5

    .line 371
    nop

    .line 362
    xor-int/lit8 v4, v4, 0x1

    add-int/lit8 v0, v0, -0x1

    goto :goto_b

    .line 373
    :cond_24
    rem-int/lit8 v3, v3, 0xa

    if-nez v3, :cond_29

    goto :goto_2a

    :cond_29
    move v1, v2

    :goto_2a
    return v1
.end method

.method static publicIpv4(Ljava/util/regex/Matcher;)Z
    .registers 7

    .line 339
    const/4 v0, 0x4

    new-array v1, v0, [I

    .line 340
    const/4 v2, 0x0

    move v3, v2

    :goto_5
    if-ge v3, v0, :cond_1a

    .line 341
    add-int/lit8 v4, v3, 0x1

    invoke-virtual {p0, v4}, Ljava/util/regex/Matcher;->group(I)Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v5

    aput v5, v1, v3

    .line 342
    const/16 v3, 0xff

    if-le v5, v3, :cond_18

    .line 343
    return v2

    .line 340
    :cond_18
    move v3, v4

    goto :goto_5

    .line 346
    :cond_1a
    aget p0, v1, v2

    if-eqz p0, :cond_5d

    const/16 v0, 0xa

    if-eq p0, v0, :cond_5d

    const/16 v0, 0x7f

    if-eq p0, v0, :cond_5d

    const/16 v3, 0xe0

    if-lt p0, v3, :cond_2b

    goto :goto_5d

    .line 349
    :cond_2b
    const/16 v3, 0xc0

    const/4 v4, 0x1

    if-ne p0, v3, :cond_36

    aget v3, v1, v4

    const/16 v5, 0xa8

    if-eq v3, v5, :cond_40

    :cond_36
    const/16 v3, 0xa9

    if-ne p0, v3, :cond_41

    aget v3, v1, v4

    const/16 v5, 0xfe

    if-ne v3, v5, :cond_41

    .line 350
    :cond_40
    return v2

    .line 352
    :cond_41
    const/16 v3, 0xac

    if-ne p0, v3, :cond_4f

    aget v3, v1, v4

    const/16 v5, 0x10

    if-lt v3, v5, :cond_4f

    const/16 v5, 0x1f

    if-le v3, v5, :cond_5b

    :cond_4f
    const/16 v3, 0x64

    if-ne p0, v3, :cond_5c

    aget p0, v1, v4

    const/16 v1, 0x40

    if-lt p0, v1, :cond_5c

    if-gt p0, v0, :cond_5c

    .line 353
    :cond_5b
    return v2

    .line 355
    :cond_5c
    return v4

    .line 347
    :cond_5d
    :goto_5d
    return v2
.end method

.method private replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;
    .registers 5

    .line 247
    invoke-virtual {p2, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object p2

    .line 248
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->find()Z

    move-result v0

    if-nez v0, :cond_b

    .line 249
    return-object p1

    .line 251
    :cond_b
    new-instance p1, Ljava/lang/StringBuffer;

    invoke-direct {p1}, Ljava/lang/StringBuffer;-><init>()V

    .line 253
    :cond_10
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->group()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p0, p3, v0}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p2, p1, v0}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 254
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->find()Z

    move-result v0

    if-nez v0, :cond_10

    .line 255
    invoke-virtual {p2, p1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 256
    invoke-virtual {p1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;
    .registers 10

    .line 260
    invoke-virtual {p2, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object p2

    .line 261
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->find()Z

    move-result v0

    if-nez v0, :cond_b

    .line 262
    return-object p1

    .line 264
    :cond_b
    new-instance p1, Ljava/lang/StringBuffer;

    invoke-direct {p1}, Ljava/lang/StringBuffer;-><init>()V

    .line 266
    :cond_10
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->group()Ljava/lang/String;

    move-result-object v0

    .line 267
    invoke-virtual {p2, p3}, Ljava/util/regex/Matcher;->start(I)I

    move-result v1

    invoke-virtual {p2}, Ljava/util/regex/Matcher;->start()I

    move-result v2

    sub-int/2addr v1, v2

    .line 268
    invoke-virtual {p2, p3}, Ljava/util/regex/Matcher;->end(I)I

    move-result v2

    invoke-virtual {p2}, Ljava/util/regex/Matcher;->start()I

    move-result v3

    sub-int/2addr v2, v3

    .line 269
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v4, 0x0

    invoke-virtual {v0, v4, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p2, p3}, Ljava/util/regex/Matcher;->group(I)Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0, p4, v3}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 270
    invoke-static {v0}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p2, p1, v0}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 271
    invoke-virtual {p2}, Ljava/util/regex/Matcher;->find()Z

    move-result v0

    if-nez v0, :cond_10

    .line 272
    invoke-virtual {p2, p1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 273
    invoke-virtual {p1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private replaceImei(Ljava/lang/String;)Ljava/lang/String;
    .registers 5

    .line 295
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->DIGITS15:Ljava/util/regex/Pattern;

    invoke-virtual {v0, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 296
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_d

    .line 297
    return-object p1

    .line 299
    :cond_d
    new-instance p1, Ljava/lang/StringBuffer;

    invoke-direct {p1}, Ljava/lang/StringBuffer;-><init>()V

    .line 301
    :cond_12
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->group()Ljava/lang/String;

    move-result-object v1

    .line 302
    invoke-static {v1}, Lio/mesalabs/unica/reports/Scrub;->luhn(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_22

    const-string v2, "IMEI"

    invoke-direct {p0, v2, v1}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    :cond_22
    invoke-static {v1}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, p1, v1}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 303
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_12

    .line 304
    invoke-virtual {v0, p1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 305
    invoke-virtual {p1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private replaceIpv4(Ljava/lang/String;)Ljava/lang/String;
    .registers 8

    .line 323
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->IPV4:Ljava/util/regex/Pattern;

    invoke-virtual {v0, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 324
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_d

    .line 325
    return-object p1

    .line 327
    :cond_d
    new-instance v1, Ljava/lang/StringBuffer;

    invoke-direct {v1}, Ljava/lang/StringBuffer;-><init>()V

    .line 329
    :cond_12
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->group()Ljava/lang/String;

    move-result-object v2

    .line 330
    sget-object v3, Lio/mesalabs/unica/reports/Scrub;->VERSION_BEFORE:Ljava/util/regex/Pattern;

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v4

    add-int/lit8 v4, v4, -0x10

    const/4 v5, 0x0

    invoke-static {v5, v4}, Ljava/lang/Math;->max(II)I

    move-result v4

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {p1, v4, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v3

    invoke-virtual {v3}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    .line 331
    if-nez v3, :cond_41

    invoke-static {v0}, Lio/mesalabs/unica/reports/Scrub;->publicIpv4(Ljava/util/regex/Matcher;)Z

    move-result v3

    if-eqz v3, :cond_41

    const-string v3, "IP"

    invoke-direct {p0, v3, v2}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    :cond_41
    invoke-static {v2}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 332
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v2

    if-nez v2, :cond_12

    .line 333
    invoke-virtual {v0, v1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 334
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private replaceLocation(Ljava/lang/String;)Ljava/lang/String;
    .registers 6

    .line 309
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->LOCATION:Ljava/util/regex/Pattern;

    invoke-virtual {v0, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 310
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_d

    .line 311
    return-object p1

    .line 313
    :cond_d
    new-instance p1, Ljava/lang/StringBuffer;

    invoke-direct {p1}, Ljava/lang/StringBuffer;-><init>()V

    .line 315
    :cond_12
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v2, 0x2

    invoke-virtual {v0, v2}, Ljava/util/regex/Matcher;->group(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v0, v2}, Ljava/util/regex/Matcher;->group(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "LOCATION"

    invoke-direct {p0, v2, v1}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 316
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v3, 0x1

    invoke-virtual {v0, v3}, Ljava/util/regex/Matcher;->group(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, p1, v1}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 317
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_12

    .line 318
    invoke-virtual {v0, p1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 319
    invoke-virtual {p1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private replaceMac(Ljava/lang/String;)Ljava/lang/String;
    .registers 7

    .line 277
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->MAC:Ljava/util/regex/Pattern;

    invoke-virtual {v0, p1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 278
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_d

    .line 279
    return-object p1

    .line 281
    :cond_d
    new-instance p1, Ljava/lang/StringBuffer;

    invoke-direct {p1}, Ljava/lang/StringBuffer;-><init>()V

    .line 283
    :cond_12
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->group()Ljava/lang/String;

    move-result-object v1

    .line 284
    invoke-virtual {v1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v2

    const/16 v3, 0x2d

    const/16 v4, 0x3a

    invoke-virtual {v2, v3, v4}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object v2

    .line 286
    const-string v3, "00:00:00:00:00:00"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_3d

    const-string v3, "ff:ff:ff:ff:ff:ff"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_3d

    .line 287
    const-string v3, "02:00:00:00:00:00"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_3b

    goto :goto_3d

    :cond_3b
    const/4 v3, 0x0

    goto :goto_3e

    :cond_3d
    :goto_3d
    const/4 v3, 0x1

    .line 288
    :goto_3e
    if-eqz v3, :cond_41

    goto :goto_47

    :cond_41
    const-string v1, "MAC"

    invoke-direct {p0, v1, v2}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    :goto_47
    invoke-static {v1}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, p1, v1}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    .line 289
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v1

    if-nez v1, :cond_12

    .line 290
    invoke-virtual {v0, p1}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 291
    invoke-virtual {p1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method private tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 7

    .line 234
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const/4 v1, 0x0

    .line 242
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    .line 234
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    .line 235
    iget-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->tags:Ljava/util/Map;

    invoke-interface {v0, p2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 236
    if-nez v0, :cond_63

    .line 237
    iget-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->next:Ljava/util/Map;

    invoke-interface {v0, p1, v2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    add-int/lit8 v0, v0, 0x1

    .line 238
    iget-object v1, p0, Lio/mesalabs/unica/reports/Scrub;->next:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v1, p1, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 239
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "<"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v3, "-"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ">"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 240
    iget-object v1, p0, Lio/mesalabs/unica/reports/Scrub;->tags:Ljava/util/Map;

    invoke-interface {v1, p2, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 242
    :cond_63
    iget-object p2, p0, Lio/mesalabs/unica/reports/Scrub;->counts:Ljava/util/Map;

    invoke-interface {p2, p1, v2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    add-int/lit8 v1, v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {p2, p1, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 243
    return-object v0
.end method


# virtual methods
.method addKnown(Ljava/lang/String;Ljava/lang/String;)V
    .registers 5

    .line 107
    if-nez p2, :cond_3

    .line 108
    return-void

    .line 110
    :cond_3
    invoke-virtual {p2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p2

    .line 111
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x4

    if-ge v0, v1, :cond_f

    .line 112
    return-void

    .line 114
    :cond_f
    iget-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->known:Ljava/util/List;

    filled-new-array {p2, p1}, [Ljava/lang/String;

    move-result-object p1

    invoke-interface {v0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 117
    iget-object p1, p0, Lio/mesalabs/unica/reports/Scrub;->known:Ljava/util/List;

    new-instance p2, Lio/mesalabs/unica/reports/Scrub$1;

    invoke-direct {p2, p0}, Lio/mesalabs/unica/reports/Scrub$1;-><init>(Lio/mesalabs/unica/reports/Scrub;)V

    invoke-static {p1, p2}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 123
    return-void
.end method

.method addKnownName(Ljava/lang/String;Ljava/lang/String;)V
    .registers 15

    .line 131
    if-eqz p2, :cond_a7

    invoke-virtual {p2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x4

    if-ge v0, v1, :cond_f

    goto/16 :goto_a7

    .line 134
    :cond_f
    invoke-virtual {p2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p2

    .line 135
    iget-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->names:Ljava/util/Map;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "(?<![\\w.])"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {p2}, Ljava/util/regex/Pattern;->quote(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "(?!\\w)"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v3

    invoke-interface {v0, v1, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    invoke-virtual {p0, p1, p2}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 139
    const/16 v0, 0x20

    invoke-virtual {p2, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-ltz v1, :cond_a6

    .line 140
    const/4 v1, 0x2

    new-array v3, v1, [C

    fill-array-data v3, :array_a8

    move v6, v2

    :goto_61
    if-ge v6, v1, :cond_a6

    aget-char v7, v3, v6

    .line 141
    invoke-virtual {p2, v0, v7}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object v7

    .line 142
    iget-object v8, p0, Lio/mesalabs/unica/reports/Scrub;->names:Ljava/util/Map;

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v9, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-static {v7}, Ljava/util/regex/Pattern;->quote(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v10}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v10

    invoke-interface {v8, v9, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 143
    invoke-virtual {p0, p1, v7}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 140
    add-int/lit8 v6, v6, 0x1

    goto :goto_61

    .line 146
    :cond_a6
    return-void

    .line 132
    :cond_a7
    :goto_a7
    return-void

    :array_a8
    .array-data 2
        0x2ds
        0x5fs
    .end array-data
.end method

.method scrub(Ljava/lang/String;)Ljava/lang/String;
    .registers 9

    .line 175
    if-eqz p1, :cond_154

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_a

    goto/16 :goto_154

    .line 182
    :cond_a
    const/16 v0, 0x25

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    if-ltz v0, :cond_16

    .line 183
    invoke-static {p1}, Lio/mesalabs/unica/reports/Scrub;->decodePercent(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 185
    :cond_16
    iget-object v0, p0, Lio/mesalabs/unica/reports/Scrub;->known:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1c
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    const/4 v2, 0x1

    if-eqz v1, :cond_69

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    .line 186
    const/4 v3, 0x0

    aget-object v4, v1, v3

    invoke-virtual {p1, v4}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v4

    if-eqz v4, :cond_68

    .line 187
    iget-object v4, p0, Lio/mesalabs/unica/reports/Scrub;->names:Ljava/util/Map;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    aget-object v6, v1, v2

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v5

    aget-object v6, v1, v3

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-interface {v4, v5}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/util/regex/Pattern;

    .line 188
    if-eqz v4, :cond_5c

    aget-object v1, v1, v2

    invoke-direct {p0, p1, v4, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    goto :goto_68

    :cond_5c
    aget-object v3, v1, v3

    aget-object v1, v1, v2

    invoke-direct {p0, v1, v3}, Lio/mesalabs/unica/reports/Scrub;->tag(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v3, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p1

    .line 190
    :cond_68
    :goto_68
    goto :goto_1c

    .line 191
    :cond_69
    const/16 v0, 0x40

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    if-ltz v0, :cond_79

    .line 192
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->EMAIL:Ljava/util/regex/Pattern;

    const-string v1, "EMAIL"

    invoke-direct {p0, p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 194
    :cond_79
    const-string v0, ".local"

    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_89

    .line 195
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->HOST:Ljava/util/regex/Pattern;

    const-string v1, "HOST"

    invoke-direct {p0, p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 197
    :cond_89
    const/16 v0, 0x3a

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-gez v1, :cond_99

    const/16 v1, 0x2d

    invoke-virtual {p1, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-ltz v1, :cond_9d

    .line 198
    :cond_99
    invoke-direct {p0, p1}, Lio/mesalabs/unica/reports/Scrub;->replaceMac(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 200
    :cond_9d
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->SUBSCRIBER:Ljava/util/regex/Pattern;

    const-string v3, "SUBSCRIBER"

    const/4 v4, 0x3

    invoke-direct {p0, p1, v1, v4, v3}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 201
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v1

    const/16 v3, 0x13

    if-lt v1, v3, :cond_be

    const-string v1, "89"

    invoke-virtual {p1, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    if-ltz v1, :cond_be

    .line 202
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->ICCID:Ljava/util/regex/Pattern;

    const-string v3, "ICCID"

    invoke-direct {p0, p1, v1, v3}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 204
    :cond_be
    invoke-direct {p0, p1}, Lio/mesalabs/unica/reports/Scrub;->replaceImei(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 205
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->PHONE:Ljava/util/regex/Pattern;

    const-string v3, "PHONE"

    invoke-direct {p0, p1, v1, v3}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 206
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->SSID_HEX:Ljava/util/regex/Pattern;

    const/4 v3, 0x2

    const-string v5, "SSID"

    invoke-direct {p0, p1, v1, v3, v5}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 207
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->SSID:Ljava/util/regex/Pattern;

    invoke-direct {p0, p1, v1, v3, v5}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 208
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->SAMSUNG_WIFI:Ljava/util/regex/Pattern;

    invoke-direct {p0, p1, v1, v2, v5}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 209
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->HARDWARE_ID:Ljava/util/regex/Pattern;

    const-string v5, "ID"

    invoke-direct {p0, p1, v1, v3, v5}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 210
    const-string v1, "\uc758"

    invoke-virtual {p1, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_f7

    const-string v1, "\'s"

    invoke-virtual {p1, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_ff

    .line 211
    :cond_f7
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->POSSESSIVE:Ljava/util/regex/Pattern;

    const-string v5, "NAME"

    invoke-direct {p0, p1, v1, v2, v5}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 213
    :cond_ff
    const-string v1, "Location["

    invoke-virtual {p1, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_10b

    .line 214
    invoke-direct {p0, p1}, Lio/mesalabs/unica/reports/Scrub;->replaceLocation(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 216
    :cond_10b
    sget-object v1, Lio/mesalabs/unica/reports/Scrub;->LATLON:Ljava/util/regex/Pattern;

    const-string v2, "LOCATION"

    invoke-direct {p0, p1, v1, v4, v2}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 217
    const/16 v1, 0x2e

    invoke-virtual {p1, v1}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-ltz v1, :cond_11f

    .line 218
    invoke-direct {p0, p1}, Lio/mesalabs/unica/reports/Scrub;->replaceIpv4(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 220
    :cond_11f
    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    if-ltz v0, :cond_12d

    .line 221
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->IPV6:Ljava/util/regex/Pattern;

    const-string v1, "IP"

    invoke-direct {p0, p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 223
    :cond_12d
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    const/16 v1, 0x78

    if-lt v0, v1, :cond_13d

    .line 224
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->TOKEN:Ljava/util/regex/Pattern;

    const-string v1, "TOKEN"

    invoke-direct {p0, p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 226
    :cond_13d
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->KERNEL_ID:Ljava/util/regex/Pattern;

    const-string v1, "SERIAL"

    invoke-direct {p0, p1, v0, v3, v1}, Lio/mesalabs/unica/reports/Scrub;->replaceGroup(Ljava/lang/String;Ljava/util/regex/Pattern;ILjava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 227
    const/16 v0, 0x52

    invoke-virtual {p1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    if-ltz v0, :cond_153

    .line 228
    sget-object v0, Lio/mesalabs/unica/reports/Scrub;->SAMSUNG_SERIAL:Ljava/util/regex/Pattern;

    invoke-direct {p0, p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->replace(Ljava/lang/String;Ljava/util/regex/Pattern;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    .line 230
    :cond_153
    return-object p1

    .line 176
    :cond_154
    :goto_154
    return-object p1
.end method
