.class public final Lio/mesalabs/unica/reports/BugReport;
.super Landroid/app/Activity;
.source "BugReport.java"


# static fields
.field private static final BUFFERS:[Ljava/lang/String;

.field private static final DROPBOX_MAX_CHARS:I = 0x40000

.field private static final DROPBOX_MAX_ENTRIES:I = 0xc8

.field private static final DROPBOX_WINDOW:J = 0x5265c00L

.field private static final PROPS:[Ljava/lang/String;

.field private static final TAG:Ljava/lang/String; = "BugReport"

.field private static volatile sRunning:Z


# direct methods
.method static constructor <clinit>()V
    .registers 16

    .line 70
    const-string v0, "events"

    const-string v1, "radio"

    const-string v2, "main"

    const-string v3, "system"

    const-string v4, "crash"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/BugReport;->BUFFERS:[Ljava/lang/String;

    .line 74
    const-string v1, "ro.unica.version"

    const-string v2, "ro.unica.timestamp"

    const-string v3, "ro.unica.device"

    const-string v4, "ro.build.display.id"

    const-string v5, "ro.product.vendor.device"

    const-string v6, "ro.product.vendor.model"

    const-string v7, "ro.bootloader"

    const-string v8, "ro.csc.sales_code"

    const-string v9, "ril.official_cscver"

    const-string v10, "ril.sw_ver"

    const-string v11, "ro.build.version.release"

    const-string v12, "ro.build.version.security_patch"

    const-string v13, "ro.boot.verifiedbootstate"

    const-string v14, "ro.boot.warranty_bit"

    const-string v15, "persist.sys.locale"

    filled-new-array/range {v1 .. v15}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lio/mesalabs/unica/reports/BugReport;->PROPS:[Ljava/lang/String;

    return-void
.end method

.method public constructor <init>()V
    .registers 1

    .line 67
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method

.method static synthetic access$000(Landroid/app/Activity;Ljava/lang/String;)V
    .registers 2

    .line 67
    invoke-static {p0, p1}, Lio/mesalabs/unica/reports/BugReport;->run(Landroid/app/Activity;Ljava/lang/String;)V

    return-void
.end method

.method static synthetic access$100(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .registers 4

    .line 67
    invoke-static {p0, p1, p2, p3}, Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$202(Z)Z
    .registers 1

    .line 67
    sput-boolean p0, Lio/mesalabs/unica/reports/BugReport;->sRunning:Z

    return p0
.end method

.method static synthetic access$300(Landroid/app/Activity;Ljava/io/File;)V
    .registers 2

    .line 67
    invoke-static {p0, p1}, Lio/mesalabs/unica/reports/BugReport;->share(Landroid/app/Activity;Ljava/io/File;)V

    return-void
.end method

.method static addKnown(Landroid/content/Context;Lio/mesalabs/unica/reports/Scrub;)V
    .registers 7

    .line 360
    const-string v0, "NAME"

    :try_start_2
    const-string v1, "SERIAL"

    invoke-static {}, Landroid/os/Build;->getSerial()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v1, v2}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_b
    .catchall {:try_start_2 .. :try_end_b} :catchall_c

    .line 362
    goto :goto_d

    .line 361
    :catchall_c
    move-exception v1

    .line 364
    :goto_d
    :try_start_d
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "device_name"

    invoke-static {v1, v2}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 365
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "bluetooth_name"

    invoke-static {v1, v2}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v0, v1}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_27
    .catchall {:try_start_d .. :try_end_27} :catchall_28

    .line 367
    goto :goto_29

    .line 366
    :catchall_28
    move-exception v0

    .line 369
    :goto_29
    :try_start_29
    invoke-static {p0}, Landroid/accounts/AccountManager;->get(Landroid/content/Context;)Landroid/accounts/AccountManager;

    move-result-object v0

    invoke-virtual {v0}, Landroid/accounts/AccountManager;->getAccounts()[Landroid/accounts/Account;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_33
    if-ge v2, v1, :cond_41

    aget-object v3, v0, v2

    .line 370
    const-string v4, "ACCOUNT"

    iget-object v3, v3, Landroid/accounts/Account;->name:Ljava/lang/String;

    invoke-virtual {p1, v4, v3}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_3e
    .catchall {:try_start_29 .. :try_end_3e} :catchall_42

    .line 369
    add-int/lit8 v2, v2, 0x1

    goto :goto_33

    .line 373
    :cond_41
    goto :goto_43

    .line 372
    :catchall_42
    move-exception v0

    .line 375
    :goto_43
    :try_start_43
    const-class v0, Landroid/telephony/TelephonyManager;

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/telephony/TelephonyManager;

    .line 376
    if-eqz v0, :cond_71

    .line 377
    const-string v1, "PHONE"

    invoke-virtual {v0}, Landroid/telephony/TelephonyManager;->getLine1Number()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v1, v2}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 378
    const-string v1, "IMEI"

    invoke-virtual {v0}, Landroid/telephony/TelephonyManager;->getImei()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v1, v2}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 379
    const-string v1, "SUBSCRIBER"

    invoke-virtual {v0}, Landroid/telephony/TelephonyManager;->getSubscriberId()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v1, v2}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V

    .line 380
    const-string v1, "ICCID"

    invoke-virtual {v0}, Landroid/telephony/TelephonyManager;->getSimSerialNumber()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v1, v0}, Lio/mesalabs/unica/reports/Scrub;->addKnown(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_71
    .catchall {:try_start_43 .. :try_end_71} :catchall_72

    .line 383
    :cond_71
    goto :goto_73

    .line 382
    :catchall_72
    move-exception v0

    .line 385
    :goto_73
    :try_start_73
    const-class v0, Landroid/net/wifi/WifiManager;

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/net/wifi/WifiManager;

    .line 386
    if-eqz p0, :cond_a9

    .line 387
    invoke-virtual {p0}, Landroid/net/wifi/WifiManager;->getConfiguredNetworks()Ljava/util/List;

    move-result-object p0

    .line 388
    if-eqz p0, :cond_a9

    .line 389
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_87
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_a9

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/net/wifi/WifiConfiguration;

    .line 390
    if-eqz v0, :cond_a8

    iget-object v1, v0, Landroid/net/wifi/WifiConfiguration;->SSID:Ljava/lang/String;

    if-eqz v1, :cond_a8

    .line 391
    iget-object v0, v0, Landroid/net/wifi/WifiConfiguration;->SSID:Ljava/lang/String;

    const-string v1, "^\"|\"$"

    const-string v2, ""

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 392
    const-string v1, "SSID"

    invoke-virtual {p1, v1, v0}, Lio/mesalabs/unica/reports/Scrub;->addKnownName(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_a8
    .catchall {:try_start_73 .. :try_end_a8} :catchall_aa

    .line 394
    :cond_a8
    goto :goto_87

    .line 398
    :cond_a9
    goto :goto_ab

    .line 397
    :catchall_aa
    move-exception p0

    .line 400
    :goto_ab
    :try_start_ab
    invoke-static {}, Landroid/bluetooth/BluetoothAdapter;->getDefaultAdapter()Landroid/bluetooth/BluetoothAdapter;

    move-result-object p0

    .line 401
    if-eqz p0, :cond_d9

    .line 402
    invoke-virtual {p0}, Landroid/bluetooth/BluetoothAdapter;->getBondedDevices()Ljava/util/Set;

    move-result-object p0

    .line 403
    if-eqz p0, :cond_d9

    .line 404
    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_bb
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_d9

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/bluetooth/BluetoothDevice;

    .line 405
    if-eqz v0, :cond_d8

    invoke-virtual {v0}, Landroid/bluetooth/BluetoothDevice;->getName()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_d8

    .line 406
    const-string v1, "BT_DEVICE"

    invoke-virtual {v0}, Landroid/bluetooth/BluetoothDevice;->getName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v1, v0}, Lio/mesalabs/unica/reports/Scrub;->addKnownName(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_d8
    .catchall {:try_start_ab .. :try_end_d8} :catchall_da

    .line 408
    :cond_d8
    goto :goto_bb

    .line 412
    :cond_d9
    goto :goto_db

    .line 411
    :catchall_da
    move-exception p0

    .line 413
    :goto_db
    return-void
.end method

.method private static varargs command(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;[Ljava/lang/String;)Ljava/lang/String;
    .registers 8

    .line 454
    nop

    .line 456
    const/4 v0, 0x0

    :try_start_2
    new-instance v1, Ljava/lang/ProcessBuilder;

    invoke-direct {v1, p3}, Ljava/lang/ProcessBuilder;-><init>([Ljava/lang/String;)V

    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Ljava/lang/ProcessBuilder;->redirectErrorStream(Z)Ljava/lang/ProcessBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/ProcessBuilder;->start()Ljava/lang/Process;

    move-result-object v1
    :try_end_10
    .catchall {:try_start_2 .. :try_end_10} :catchall_4b

    .line 457
    :try_start_10
    invoke-virtual {v1}, Ljava/lang/Process;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v2

    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V

    .line 458
    invoke-virtual {v1}, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;

    move-result-object v2

    invoke-static {p0, p1, v2, p2}, Lio/mesalabs/unica/reports/BugReport;->lines(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/io/InputStream;Lio/mesalabs/unica/reports/Scrub;)J

    move-result-wide p0

    .line 459
    invoke-virtual {v1}, Ljava/lang/Process;->waitFor()I

    move-result p2

    .line 460
    if-eqz p2, :cond_39

    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    const-string p1, "failed, exit "

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto :goto_42

    :cond_39
    const-wide/16 v2, 0x0

    cmp-long p0, p0, v2

    if-lez p0, :cond_40

    goto :goto_42

    :cond_40
    const-string v0, "empty"
    :try_end_42
    .catchall {:try_start_10 .. :try_end_42} :catchall_48

    .line 465
    :goto_42
    if-eqz v1, :cond_47

    .line 466
    invoke-virtual {v1}, Ljava/lang/Process;->destroy()V

    .line 460
    :cond_47
    return-object v0

    .line 461
    :catchall_48
    move-exception p0

    move-object v0, v1

    goto :goto_4c

    :catchall_4b
    move-exception p0

    .line 462
    :goto_4c
    :try_start_4c
    const-string p1, "BugReport"

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "could not run "

    invoke-virtual {p2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const/4 v1, 0x0

    aget-object p3, p3, v1

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, p2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 463
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p2, "failed, "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0
    :try_end_82
    .catchall {:try_start_4c .. :try_end_82} :catchall_88

    .line 465
    if-eqz v0, :cond_87

    .line 466
    invoke-virtual {v0}, Ljava/lang/Process;->destroy()V

    .line 463
    :cond_87
    return-object p0

    .line 465
    :catchall_88
    move-exception p0

    if-eqz v0, :cond_8e

    .line 466
    invoke-virtual {v0}, Ljava/lang/Process;->destroy()V

    .line 468
    :cond_8e
    throw p0
.end method

.method private static deviceInfo(Ljava/lang/String;)Ljava/lang/String;
    .registers 8

    .line 416
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 417
    const-string v1, "UN1CA problem report\n\n"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 418
    const-string v1, "What went wrong: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    if-eqz p0, :cond_22

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1d

    goto :goto_22

    :cond_1d
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p0

    goto :goto_24

    :cond_22
    :goto_22
    const-string p0, "(not given)"

    :goto_24
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    .line 419
    const-string v1, "\n\n"

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 420
    sget-object p0, Lio/mesalabs/unica/reports/BugReport;->PROPS:[Ljava/lang/String;

    array-length v1, p0

    const/4 v2, 0x0

    :goto_31
    const/16 v3, 0xa

    if-ge v2, v1, :cond_4f

    aget-object v4, p0, v2

    .line 421
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const/16 v6, 0x3d

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {v4}, Lio/mesalabs/unica/reports/ReportUtils;->prop(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 420
    add-int/lit8 v2, v2, 0x1

    goto :goto_31

    .line 423
    :cond_4f
    const-string p0, "uptime_s="

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v1

    const-wide/16 v4, 0x3e8

    div-long/2addr v1, v4

    invoke-virtual {p0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 424
    const-string p0, "kernel="

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    new-instance v1, Ljava/io/File;

    const-string v2, "/proc/version"

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-static {v1}, Lio/mesalabs/unica/reports/BugReport;->firstLine(Ljava/io/File;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 425
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static dropbox(Landroid/content/Context;Ljava/util/zip/ZipOutputStream;Lio/mesalabs/unica/reports/Scrub;)Z
    .registers 15

    .line 500
    const/4 v0, 0x0

    :try_start_1
    const-class v1, Landroid/os/DropBoxManager;

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/os/DropBoxManager;

    .line 501
    if-nez p0, :cond_c

    .line 502
    return v0

    .line 504
    :cond_c
    new-instance v1, Ljava/util/zip/ZipEntry;

    const-string v2, "dropbox.txt"

    invoke-direct {v1, v2}, Ljava/util/zip/ZipEntry;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, v1}, Ljava/util/zip/ZipOutputStream;->putNextEntry(Ljava/util/zip/ZipEntry;)V

    .line 505
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v1

    const-wide/32 v3, 0x5265c00

    sub-long/2addr v1, v3

    .line 506
    new-instance v3, Ljava/util/ArrayList;

    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    .line 507
    move-wide v4, v1

    .line 508
    :goto_24
    const/4 v6, 0x0

    invoke-virtual {p0, v6, v4, v5}, Landroid/os/DropBoxManager;->getNextEntry(Ljava/lang/String;J)Landroid/os/DropBoxManager$Entry;

    move-result-object v4
    :try_end_29
    .catchall {:try_start_1 .. :try_end_29} :catchall_fd

    if-eqz v4, :cond_40

    .line 510
    :try_start_2b
    invoke-virtual {v4}, Landroid/os/DropBoxManager$Entry;->getTimeMillis()J

    move-result-wide v5

    .line 511
    invoke-static {v5, v6}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v7

    invoke-interface {v3, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_36
    .catchall {:try_start_2b .. :try_end_36} :catchall_3b

    .line 513
    :try_start_36
    invoke-virtual {v4}, Landroid/os/DropBoxManager$Entry;->close()V

    .line 514
    move-wide v4, v5

    goto :goto_24

    .line 513
    :catchall_3b
    move-exception p0

    invoke-virtual {v4}, Landroid/os/DropBoxManager$Entry;->close()V

    .line 514
    throw p0

    .line 516
    :cond_40
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v4

    const/16 v5, 0xc8

    if-le v4, v5, :cond_5b

    .line 517
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v1

    sub-int/2addr v1, v5

    invoke-interface {v3, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Long;

    invoke-virtual {v1}, Ljava/lang/Long;->longValue()J

    move-result-wide v1

    const-wide/16 v3, 0x1

    sub-long/2addr v1, v3

    goto :goto_5c

    .line 518
    :cond_5b
    nop

    .line 519
    :goto_5c
    move v3, v0

    .line 520
    :goto_5d
    if-ge v3, v5, :cond_f6

    invoke-virtual {p0, v6, v1, v2}, Landroid/os/DropBoxManager;->getNextEntry(Ljava/lang/String;J)Landroid/os/DropBoxManager$Entry;

    move-result-object v1
    :try_end_63
    .catchall {:try_start_36 .. :try_end_63} :catchall_fd

    if-eqz v1, :cond_f6

    .line 522
    :try_start_65
    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->getTimeMillis()J

    move-result-wide v7

    .line 523
    add-int/lit8 v3, v3, 0x1

    .line 524
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "===== "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->getTag()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v4, " @ "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    new-instance v4, Ljava/text/SimpleDateFormat;

    const-string v9, "yyyy-MM-dd HH:mm:ss"

    sget-object v10, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-direct {v4, v9, v10}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v9, Ljava/util/Date;

    .line 525
    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->getTimeMillis()J

    move-result-wide v10

    invoke-direct {v9, v10, v11}, Ljava/util/Date;-><init>(J)V

    invoke-virtual {v4, v9}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v4, " =====\n"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    .line 526
    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v2, v4}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/util/zip/ZipOutputStream;->write([B)V

    .line 527
    const/high16 v2, 0x40000

    invoke-virtual {v1, v2}, Landroid/os/DropBoxManager$Entry;->getText(I)Ljava/lang/String;

    move-result-object v2

    .line 528
    if-nez v2, :cond_c8

    .line 529
    const-string v2, "(binary entry, not included)\n"

    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v2, v4}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/util/zip/ZipOutputStream;->write([B)V
    :try_end_c4
    .catchall {:try_start_65 .. :try_end_c4} :catchall_f1

    .line 537
    :try_start_c4
    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->close()V
    :try_end_c7
    .catchall {:try_start_c4 .. :try_end_c7} :catchall_fd

    .line 530
    goto :goto_ee

    .line 532
    :cond_c8
    :try_start_c8
    const-string v4, "\n"

    const/4 v9, -0x1

    invoke-virtual {v2, v4, v9}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v2

    array-length v4, v2

    move v9, v0

    :goto_d1
    if-ge v9, v4, :cond_ea

    aget-object v10, v2, v9

    .line 533
    invoke-virtual {p2, v10}, Lio/mesalabs/unica/reports/Scrub;->scrub(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    sget-object v11, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v10, v11}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v10

    invoke-virtual {p1, v10}, Ljava/util/zip/ZipOutputStream;->write([B)V

    .line 534
    const/16 v10, 0xa

    invoke-virtual {p1, v10}, Ljava/util/zip/ZipOutputStream;->write(I)V
    :try_end_e7
    .catchall {:try_start_c8 .. :try_end_e7} :catchall_f1

    .line 532
    add-int/lit8 v9, v9, 0x1

    goto :goto_d1

    .line 537
    :cond_ea
    :try_start_ea
    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->close()V

    .line 538
    nop

    .line 520
    :goto_ee
    move-wide v1, v7

    goto/16 :goto_5d

    .line 537
    :catchall_f1
    move-exception p0

    invoke-virtual {v1}, Landroid/os/DropBoxManager$Entry;->close()V

    .line 538
    throw p0

    .line 540
    :cond_f6
    invoke-virtual {p1}, Ljava/util/zip/ZipOutputStream;->closeEntry()V
    :try_end_f9
    .catchall {:try_start_ea .. :try_end_f9} :catchall_fd

    .line 541
    if-lez v3, :cond_fc

    const/4 v0, 0x1

    :cond_fc
    return v0

    .line 542
    :catchall_fd
    move-exception p0

    .line 543
    const-string p1, "BugReport"

    const-string p2, "could not read dropbox"

    invoke-static {p1, p2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 544
    return v0
.end method

.method private static file(Ljava/util/zip/ZipOutputStream;Ljava/io/File;Lio/mesalabs/unica/reports/Scrub;)Z
    .registers 9

    .line 472
    invoke-virtual {p1}, Ljava/io/File;->canRead()Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_8

    .line 473
    return v1

    .line 475
    :cond_8
    :try_start_8
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_d
    .catchall {:try_start_8 .. :try_end_d} :catchall_2c

    .line 476
    :try_start_d
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-static {p0, v2, v0, p2}, Lio/mesalabs/unica/reports/BugReport;->lines(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/io/InputStream;Lio/mesalabs/unica/reports/Scrub;)J

    move-result-wide v2
    :try_end_15
    .catchall {:try_start_d .. :try_end_15} :catchall_22

    const-wide/16 v4, 0x0

    cmp-long p0, v2, v4

    if-lez p0, :cond_1d

    const/4 p0, 0x1

    goto :goto_1e

    :cond_1d
    move p0, v1

    .line 477
    :goto_1e
    :try_start_1e
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    :try_end_21
    .catchall {:try_start_1e .. :try_end_21} :catchall_2c

    .line 476
    return p0

    .line 475
    :catchall_22
    move-exception p0

    :try_start_23
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    :try_end_26
    .catchall {:try_start_23 .. :try_end_26} :catchall_27

    goto :goto_2b

    :catchall_27
    move-exception p2

    :try_start_28
    invoke-virtual {p0, p2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_2b
    throw p0
    :try_end_2c
    .catchall {:try_start_28 .. :try_end_2c} :catchall_2c

    .line 477
    :catchall_2c
    move-exception p0

    .line 478
    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "could not read "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "BugReport"

    invoke-static {p2, p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 479
    return v1
.end method

.method private static firstLine(Ljava/io/File;)Ljava/lang/String;
    .registers 5

    .line 549
    const-string v0, ""

    :try_start_2
    new-instance v1, Ljava/io/BufferedReader;

    new-instance v2, Ljava/io/InputStreamReader;

    new-instance v3, Ljava/io/FileInputStream;

    invoke-direct {v3, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    sget-object p0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v2, v3, p0}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V

    invoke-direct {v1, v2}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V
    :try_end_13
    .catchall {:try_start_2 .. :try_end_13} :catchall_28

    .line 551
    :try_start_13
    invoke-virtual {v1}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object p0
    :try_end_17
    .catchall {:try_start_13 .. :try_end_17} :catchall_1e

    .line 552
    if-nez p0, :cond_1a

    move-object p0, v0

    .line 553
    :cond_1a
    :try_start_1a
    invoke-virtual {v1}, Ljava/io/BufferedReader;->close()V
    :try_end_1d
    .catchall {:try_start_1a .. :try_end_1d} :catchall_28

    .line 552
    return-object p0

    .line 549
    :catchall_1e
    move-exception p0

    :try_start_1f
    invoke-virtual {v1}, Ljava/io/BufferedReader;->close()V
    :try_end_22
    .catchall {:try_start_1f .. :try_end_22} :catchall_23

    goto :goto_27

    :catchall_23
    move-exception v1

    :try_start_24
    invoke-virtual {p0, v1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_27
    throw p0
    :try_end_28
    .catchall {:try_start_24 .. :try_end_28} :catchall_28

    .line 553
    :catchall_28
    move-exception p0

    .line 554
    return-object v0
.end method

.method private static lines(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/io/InputStream;Lio/mesalabs/unica/reports/Scrub;)J
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 484
    new-instance v0, Ljava/util/zip/ZipEntry;

    invoke-direct {v0, p1}, Ljava/util/zip/ZipEntry;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Ljava/util/zip/ZipOutputStream;->putNextEntry(Ljava/util/zip/ZipEntry;)V

    .line 485
    nop

    .line 486
    new-instance p1, Ljava/io/BufferedReader;

    new-instance v0, Ljava/io/InputStreamReader;

    sget-object v1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v0, p2, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V

    invoke-direct {p1, v0}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 487
    const-wide/16 v0, 0x0

    .line 488
    :goto_17
    invoke-virtual {p1}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object p2

    if-eqz p2, :cond_33

    .line 489
    invoke-virtual {p3, p2}, Lio/mesalabs/unica/reports/Scrub;->scrub(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {p2, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object p2

    invoke-virtual {p0, p2}, Ljava/io/OutputStream;->write([B)V

    .line 490
    const/16 p2, 0xa

    invoke-virtual {p0, p2}, Ljava/io/OutputStream;->write(I)V

    .line 491
    const-wide/16 v2, 0x1

    add-long/2addr v0, v2

    goto :goto_17

    .line 493
    :cond_33
    invoke-virtual {p0}, Ljava/util/zip/ZipOutputStream;->closeEntry()V

    .line 494
    return-wide v0
.end method

.method private static pleaseWait(Landroid/app/Activity;)Landroid/app/AlertDialog;
    .registers 6

    .line 223
    invoke-static {p0}, Lio/mesalabs/unica/reports/BugReport;->working(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v0

    .line 224
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-direct {v1, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    .line 225
    const-string v2, "layout"

    const-string v3, "unica_bugreport_please_wait_layout"

    invoke-static {p0, v2, v3}, Lio/mesalabs/unica/reports/ReportUtils;->res(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v2

    .line 226
    const/4 v3, 0x0

    if-nez v2, :cond_1b

    move-object v2, v3

    goto :goto_23

    :cond_1b
    invoke-static {p0}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object v4

    invoke-virtual {v4, v2, v3}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v2

    .line 227
    :goto_23
    if-nez v2, :cond_26

    goto :goto_35

    .line 228
    :cond_26
    const-string v3, "id"

    const-string v4, "progress_content"

    invoke-static {p0, v3, v4}, Lio/mesalabs/unica/reports/ReportUtils;->res(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    invoke-virtual {v2, p0}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object p0

    move-object v3, p0

    check-cast v3, Landroid/widget/TextView;

    .line 229
    :goto_35
    if-eqz v3, :cond_3e

    .line 230
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 231
    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    goto :goto_41

    .line 233
    :cond_3e
    invoke-virtual {v1, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 235
    :goto_41
    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p0

    .line 236
    invoke-virtual {p0}, Landroid/app/AlertDialog;->getWindow()Landroid/view/Window;

    move-result-object v0

    .line 237
    if-eqz v0, :cond_50

    .line 238
    const/16 v1, 0x50

    invoke-virtual {v0, v1}, Landroid/view/Window;->setGravity(I)V

    .line 240
    :cond_50
    invoke-virtual {p0}, Landroid/app/AlertDialog;->show()V

    .line 241
    return-object p0
.end method

.method private static readme(Lio/mesalabs/unica/reports/Scrub;Ljava/util/List;J)Ljava/lang/String;
    .registers 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/mesalabs/unica/reports/Scrub;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;J)",
            "Ljava/lang/String;"
        }
    .end annotation

    .line 429
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 430
    const-string v1, "Made on the device by Settings > UN1CA Settings > Create problem report.\n"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 431
    const-string v1, "Identifiers were replaced by tags such as <MAC-1>; the same value always has the same tag.\n"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 432
    const-string v1, "Replaced (count per kind): "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object p0, p0, Lio/mesalabs/unica/reports/Scrub;->counts:Ljava/util/Map;

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    const/16 v1, 0xa

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 433
    const-string p0, "Not included: "

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_2f

    const-string p1, "nothing"

    goto :goto_33

    :cond_2f
    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    :goto_33
    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 434
    const-string p0, "Took "

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-wide/16 v1, 0x3e8

    div-long/2addr p2, v1

    invoke-virtual {p0, p2, p3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string p1, " s\n"

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 435
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static run(Landroid/app/Activity;Ljava/lang/String;)V
    .registers 6

    .line 149
    invoke-virtual {p0}, Landroid/app/Activity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    .line 150
    invoke-static {p0}, Lio/mesalabs/unica/reports/BugReport;->pleaseWait(Landroid/app/Activity;)Landroid/app/AlertDialog;

    move-result-object v1

    .line 151
    const/4 v2, 0x1

    sput-boolean v2, Lio/mesalabs/unica/reports/BugReport;->sRunning:Z

    .line 152
    new-instance v2, Ljava/lang/Thread;

    new-instance v3, Lio/mesalabs/unica/reports/BugReport$3;

    invoke-direct {v3, v0, p1, v1, p0}, Lio/mesalabs/unica/reports/BugReport$3;-><init>(Landroid/content/Context;Ljava/lang/String;Landroid/app/AlertDialog;Landroid/app/Activity;)V

    const-string p0, "BugReport"

    invoke-direct {v2, v3, p0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    .line 215
    invoke-virtual {v2}, Ljava/lang/Thread;->start()V

    .line 216
    return-void
.end method

.method private static share(Landroid/app/Activity;Ljava/io/File;)V
    .registers 5

    .line 251
    invoke-virtual {p0}, Landroid/app/Activity;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    .line 252
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object p1

    filled-new-array {p1}, [Ljava/lang/String;

    move-result-object p1

    const-string v1, "application/zip"

    filled-new-array {v1}, [Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lio/mesalabs/unica/reports/BugReport$4;

    invoke-direct {v2, v0, p0}, Lio/mesalabs/unica/reports/BugReport$4;-><init>(Landroid/content/Context;Landroid/app/Activity;)V

    invoke-static {v0, p1, v1, v2}, Landroid/media/MediaScannerConnection;->scanFile(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;Landroid/media/MediaScannerConnection$OnScanCompletedListener;)V

    .line 289
    return-void
.end method

.method static start(Landroid/app/Activity;)V
    .registers 9

    .line 95
    sget-boolean v0, Lio/mesalabs/unica/reports/BugReport;->sRunning:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_14

    .line 96
    invoke-static {p0}, Lio/mesalabs/unica/reports/BugReport;->working(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 97
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V

    .line 98
    return-void

    .line 100
    :cond_14
    const-string v0, "Your phone\'s logs will be collected into a single file. Serial numbers, phone numbers, account names, network names, and addresses will be hidden before the file is saved. The file won\'t be sent anywhere."

    new-array v2, v1, [Ljava/lang/Object;

    const-string v3, "unica_bugreport_intro"

    invoke-static {p0, v3, v0, v2}, Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 107
    nop

    .line 108
    nop

    .line 109
    const-string v2, "layout"

    const-string v3, "dialog_edittext"

    invoke-static {p0, v2, v3}, Lio/mesalabs/unica/reports/ReportUtils;->res(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v2

    .line 110
    const/4 v3, 0x0

    if-eqz v2, :cond_42

    .line 111
    invoke-static {p0}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object v4

    invoke-virtual {v4, v2, v3}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v2

    .line 112
    const-string v4, "id"

    const-string v5, "edittext"

    invoke-static {p0, v4, v5}, Lio/mesalabs/unica/reports/ReportUtils;->res(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v4

    invoke-virtual {v2, v4}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v4

    check-cast v4, Landroid/widget/EditText;

    goto :goto_44

    .line 110
    :cond_42
    move-object v2, v3

    move-object v4, v2

    .line 114
    :goto_44
    if-nez v4, :cond_4c

    .line 115
    new-instance v2, Landroid/widget/EditText;

    invoke-direct {v2, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 116
    move-object v4, v2

    .line 118
    :cond_4c
    new-array v5, v1, [Landroid/text/InputFilter;

    invoke-virtual {v4, v5}, Landroid/widget/EditText;->setFilters([Landroid/text/InputFilter;)V

    .line 119
    const-string v5, "Describe the problem (optional)"

    new-array v6, v1, [Ljava/lang/Object;

    const-string v7, "unica_bugreport_hint"

    invoke-static {p0, v7, v5, v6}, Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 120
    new-instance v5, Landroid/app/AlertDialog$Builder;

    invoke-direct {v5, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-static {p0}, Lio/mesalabs/unica/reports/BugReport;->title(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v5

    invoke-virtual {v5, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 121
    nop

    .line 122
    const/4 v5, 0x1

    new-array v5, v5, [Z

    aput-boolean v1, v5, v1

    .line 123
    invoke-virtual {v0, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-array v1, v1, [Ljava/lang/Object;

    .line 124
    const-string v2, "unica_bugreport_create"

    const-string v6, "Create"

    invoke-static {p0, v2, v6, v1}, Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Lio/mesalabs/unica/reports/BugReport$2;

    invoke-direct {v2, v5, p0, v4}, Lio/mesalabs/unica/reports/BugReport$2;-><init>([ZLandroid/app/Activity;Landroid/widget/EditText;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 132
    const/high16 v1, 0x1040000

    invoke-virtual {v0, v1, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lio/mesalabs/unica/reports/BugReport$1;

    invoke-direct {v1, v5, p0}, Lio/mesalabs/unica/reports/BugReport$1;-><init>([ZLandroid/app/Activity;)V

    .line 133
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 141
    invoke-virtual {p0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 142
    return-void
.end method

.method private static text(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;)V
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 439
    new-instance v0, Ljava/util/zip/ZipEntry;

    invoke-direct {v0, p1}, Ljava/util/zip/ZipEntry;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Ljava/util/zip/ZipOutputStream;->putNextEntry(Ljava/util/zip/ZipEntry;)V

    .line 440
    const-string p1, "\n"

    const/4 v0, -0x1

    invoke-virtual {p2, p1, v0}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object p1

    .line 441
    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    .line 442
    array-length v0, p1

    const/4 v1, 0x0

    :goto_16
    if-ge v1, v0, :cond_2d

    aget-object v2, p1, v1

    .line 443
    if-nez p3, :cond_1d

    goto :goto_21

    :cond_1d
    invoke-virtual {p3, v2}, Lio/mesalabs/unica/reports/Scrub;->scrub(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    :goto_21
    invoke-virtual {p2, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const/16 v3, 0xa

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 442
    add-int/lit8 v1, v1, 0x1

    goto :goto_16

    .line 445
    :cond_2d
    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    sget-object p2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {p1, p2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object p1

    invoke-virtual {p0, p1}, Ljava/util/zip/ZipOutputStream;->write([B)V

    .line 446
    invoke-virtual {p0}, Ljava/util/zip/ZipOutputStream;->closeEntry()V

    .line 447
    return-void
.end method

.method static title(Landroid/content/Context;)Ljava/lang/String;
    .registers 3

    .line 90
    const-string v0, "unica_bugreport_title"

    const-string v1, "Create problem report"

    invoke-static {p0, v0, v1}, Lio/mesalabs/unica/reports/ReportUtils;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static varargs tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .registers 5

    .line 559
    array-length v0, p3

    if-nez v0, :cond_8

    invoke-static {p0, p1, p2}, Lio/mesalabs/unica/reports/ReportUtils;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    goto :goto_c

    .line 560
    :cond_8
    invoke-static {p0, p1, p2, p3}, Lio/mesalabs/unica/reports/ReportUtils;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    .line 559
    :goto_c
    return-object p0
.end method

.method private static working(Landroid/content/Context;)Ljava/lang/String;
    .registers 4

    .line 145
    const/4 v0, 0x0

    new-array v0, v0, [Ljava/lang/Object;

    const-string v1, "unica_bugreport_working"

    const-string v2, "Collecting logs\u2026\nThis may take a few minutes."

    invoke-static {p0, v1, v2, v0}, Lio/mesalabs/unica/reports/BugReport;->tr(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static write(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;
    .registers 20
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 293
    move-object/from16 v0, p0

    new-instance v1, Ljava/io/File;

    invoke-static {}, Lio/mesalabs/unica/reports/ReportUtils;->dir()Ljava/io/File;

    move-result-object v2

    const-string v3, "reports"

    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 294
    invoke-virtual {v1}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_33

    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-eqz v2, :cond_1a

    goto :goto_33

    .line 295
    :cond_1a
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "cannot create "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 297
    :cond_33
    :goto_33
    new-instance v2, Ljava/text/SimpleDateFormat;

    const-string v3, "yyyyMMdd_HHmmss"

    sget-object v4, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-direct {v2, v3, v4}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v3, Ljava/util/Date;

    invoke-direct {v3}, Ljava/util/Date;-><init>()V

    invoke-virtual {v2, v3}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v2

    .line 298
    new-instance v3, Ljava/io/File;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "UN1CA_report_"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v4, ".zip"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v3, v1, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 299
    new-instance v2, Ljava/io/File;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, ".part"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v2, v1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 301
    new-instance v1, Lio/mesalabs/unica/reports/Scrub;

    invoke-direct {v1}, Lio/mesalabs/unica/reports/Scrub;-><init>()V

    .line 302
    invoke-static {v0, v1}, Lio/mesalabs/unica/reports/BugReport;->addKnown(Landroid/content/Context;Lio/mesalabs/unica/reports/Scrub;)V

    .line 303
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 304
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v5

    .line 305
    new-instance v7, Ljava/util/zip/ZipOutputStream;

    new-instance v8, Ljava/io/BufferedOutputStream;

    new-instance v9, Ljava/io/FileOutputStream;

    invoke-direct {v9, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v8, v9}, Ljava/io/BufferedOutputStream;-><init>(Ljava/io/OutputStream;)V

    invoke-direct {v7, v8}, Ljava/util/zip/ZipOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 307
    :try_start_9f
    const-string v8, "device.txt"

    invoke-static/range {p1 .. p1}, Lio/mesalabs/unica/reports/BugReport;->deviceInfo(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-static {v7, v8, v9, v1}, Lio/mesalabs/unica/reports/BugReport;->text(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;)V

    .line 308
    sget-object v8, Lio/mesalabs/unica/reports/BugReport;->BUFFERS:[Ljava/lang/String;

    array-length v9, v8
    :try_end_ab
    .catchall {:try_start_9f .. :try_end_ab} :catchall_1ba

    const/4 v10, 0x0

    move v11, v10

    :goto_ad
    const-string v12, ")"

    if-ge v11, v9, :cond_11d

    :try_start_b1
    aget-object v15, v8, v11

    .line 309
    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "logcat_"

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    const-string v14, ".txt"

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    const/4 v14, 0x6

    new-array v14, v14, [Ljava/lang/String;

    const-string v17, "logcat"

    aput-object v17, v14, v10

    const-string v17, "-d"

    const/16 v16, 0x1

    aput-object v17, v14, v16

    const-string v16, "-b"

    const/16 v17, 0x2

    aput-object v16, v14, v17

    const/16 v16, 0x3

    aput-object v15, v14, v16

    const-string v16, "-v"

    const/16 v17, 0x4

    aput-object v16, v14, v17

    const-string v16, "threadtime"

    const/16 v17, 0x5

    aput-object v16, v14, v17

    invoke-static {v7, v13, v1, v14}, Lio/mesalabs/unica/reports/BugReport;->command(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;[Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    .line 310
    if-eqz v13, :cond_119

    .line 311
    new-instance v14, Ljava/lang/StringBuilder;

    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "logcat -b "

    invoke-virtual {v14, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v14, " ("

    invoke-virtual {v10, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-interface {v4, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 308
    :cond_119
    add-int/lit8 v11, v11, 0x1

    const/4 v10, 0x0

    goto :goto_ad

    .line 316
    :cond_11d
    const-string v8, "dumpsys_input.txt"

    const/4 v9, 0x2

    new-array v10, v9, [Ljava/lang/String;

    const-string v9, "dumpsys"

    const/4 v11, 0x0

    aput-object v9, v10, v11

    const-string v9, "input"

    const/4 v11, 0x1

    aput-object v9, v10, v11

    invoke-static {v7, v8, v1, v10}, Lio/mesalabs/unica/reports/BugReport;->command(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;[Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 317
    if-eqz v8, :cond_14c

    .line 318
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "dumpsys input ("

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-interface {v4, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 322
    :cond_14c
    const-string v8, "kernel log (no permission)"

    invoke-interface {v4, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 323
    invoke-static {v0, v7, v1}, Lio/mesalabs/unica/reports/BugReport;->dropbox(Landroid/content/Context;Ljava/util/zip/ZipOutputStream;Lio/mesalabs/unica/reports/Scrub;)Z

    move-result v0

    if-nez v0, :cond_15c

    .line 324
    const-string v0, "dropbox"

    invoke-interface {v4, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 326
    :cond_15c
    const/4 v0, 0x2

    new-array v8, v0, [Ljava/lang/String;

    const-string v0, "/cache/recovery/last_install"

    const/4 v9, 0x0

    aput-object v0, v8, v9

    const-string v0, "/cache/recovery/last_log"

    const/4 v10, 0x1

    aput-object v0, v8, v10

    move v10, v9

    :goto_16a
    const/4 v0, 0x2

    if-ge v10, v0, :cond_180

    aget-object v9, v8, v10

    .line 327
    new-instance v11, Ljava/io/File;

    invoke-direct {v11, v9}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-static {v7, v11, v1}, Lio/mesalabs/unica/reports/BugReport;->file(Ljava/util/zip/ZipOutputStream;Ljava/io/File;Lio/mesalabs/unica/reports/Scrub;)Z

    move-result v11

    if-nez v11, :cond_17d

    .line 328
    invoke-interface {v4, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 326
    :cond_17d
    add-int/lit8 v10, v10, 0x1

    goto :goto_16a

    .line 331
    :cond_180
    const-string v0, "README.txt"

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v8

    sub-long/2addr v8, v5

    invoke-static {v1, v4, v8, v9}, Lio/mesalabs/unica/reports/BugReport;->readme(Lio/mesalabs/unica/reports/Scrub;Ljava/util/List;J)Ljava/lang/String;

    move-result-object v1

    const/4 v4, 0x0

    invoke-static {v7, v0, v1, v4}, Lio/mesalabs/unica/reports/BugReport;->text(Ljava/util/zip/ZipOutputStream;Ljava/lang/String;Ljava/lang/String;Lio/mesalabs/unica/reports/Scrub;)V
    :try_end_18f
    .catchall {:try_start_b1 .. :try_end_18f} :catchall_1ba

    .line 339
    nop

    .line 343
    :try_start_190
    invoke-virtual {v7}, Ljava/util/zip/ZipOutputStream;->close()V
    :try_end_193
    .catchall {:try_start_190 .. :try_end_193} :catchall_1b4

    .line 347
    nop

    .line 348
    invoke-virtual {v2, v3}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v0

    if-eqz v0, :cond_19b

    .line 351
    return-object v3

    .line 349
    :cond_19b
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "cannot rename "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 344
    :catchall_1b4
    move-exception v0

    move-object v1, v0

    .line 345
    invoke-virtual {v2}, Ljava/io/File;->delete()Z

    .line 346
    throw v1

    .line 332
    :catchall_1ba
    move-exception v0

    move-object v1, v0

    .line 334
    :try_start_1bc
    invoke-virtual {v7}, Ljava/util/zip/ZipOutputStream;->close()V
    :try_end_1bf
    .catchall {:try_start_1bc .. :try_end_1bf} :catchall_1c0

    .line 336
    goto :goto_1c1

    .line 335
    :catchall_1c0
    move-exception v0

    .line 337
    :goto_1c1
    invoke-virtual {v2}, Ljava/io/File;->delete()Z

    .line 338
    throw v1
.end method


# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
    .registers 2

    .line 85
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 86
    invoke-static {p0}, Lio/mesalabs/unica/reports/BugReport;->start(Landroid/app/Activity;)V

    .line 87
    return-void
.end method
