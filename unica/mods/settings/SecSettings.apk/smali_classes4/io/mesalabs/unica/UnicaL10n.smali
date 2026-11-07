.class public final Lio/mesalabs/unica/UnicaL10n;
.super Ljava/lang/Object;
.source "UnicaL10n.java"

# UN1CA: Korean strings for the UN1CA Settings screens that are built in code.

.field private static sMap:Ljava/util/HashMap;

.method public static t(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    if-nez p0, :cond_0

    return-object p0

    :cond_0
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    move-result-object v0

    const-string v1, "ko"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    return-object p0

    :cond_1
    invoke-static {}, Lio/mesalabs/unica/UnicaL10n;->map()Ljava/util/HashMap;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_2

    return-object p0

    :cond_2
    check-cast v0, Ljava/lang/String;

    return-object v0
.end method

.method private static declared-synchronized map()Ljava/util/HashMap;
    .locals 1

    sget-object v0, Lio/mesalabs/unica/UnicaL10n;->sMap:Ljava/util/HashMap;

    if-nez v0, :cond_0

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    invoke-static {v0}, Lio/mesalabs/unica/UnicaL10n;->fill0(Ljava/util/HashMap;)V

    invoke-static {v0}, Lio/mesalabs/unica/UnicaL10n;->fill1(Ljava/util/HashMap;)V

    invoke-static {v0}, Lio/mesalabs/unica/UnicaL10n;->fill2(Ljava/util/HashMap;)V

    sput-object v0, Lio/mesalabs/unica/UnicaL10n;->sMap:Ljava/util/HashMap;

    :cond_0
    return-object v0
.end method

.method private static fill0(Ljava/util/HashMap;)V
    .locals 2

    const-string v0, "\nApp-state changes await restart."

    const-string v1, "\n\uc571 \uc0c1\ud0dc \ubcc0\uacbd\uc740 \ub2e4\uc2dc \uc2dc\uc791\ud55c \ub4a4 \uc801\uc6a9\ub429\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nComplete values to write:\n"

    const-string v1, "\n\uae30\ub85d\ud560 \uc804\uccb4 \uac12:\n"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nExperimental values can freeze the GPU or prevent booting. Requests are not millivolts; the driver rounds to available corners. Raw request 1 is not a standard named corner. Neither stock nor red values guarantee stability. Keep the matching recovery rollback available."

    const-string v1, "\n\uc2e4\ud5d8\uc801 \uac12\uc740 GPU\ub97c \uba48\ucd94\uac8c \ud558\uac70\ub098 \ubd80\ud305\uc744 \ub9c9\uc744 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc694\uccad \uac12\uc740 \ubc00\ub9ac\ubcfc\ud2b8\uac00 \uc544\ub2c8\uba70 \ub4dc\ub77c\uc774\ubc84\uac00 \uc0ac\uc6a9 \uac00\ub2a5\ud55c \ucf54\ub108\ub85c \ub9de\ucda5\ub2c8\ub2e4. \uc6d0\uc2dc \uc694\uccad \uac12 1\uc740 \ud45c\uc900 \ucf54\ub108\uac00 \uc544\ub2d9\ub2c8\ub2e4. \uc21c\uc815 \uac12\ub3c4 \ube68\uac04 \uac12\ub3c4 \uc548\uc815\uc131\uc744 \ubcf4\uc7a5\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4. \ub9de\ub294 \ub9ac\ucee4\ubc84\ub9ac \ub864\ubc31\uc744 \uc900\ube44\ud574 \ub450\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nKernel: "

    const-string v1, "\n\ucee4\ub110: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nRelease: "

    const-string v1, "\n\ub9b4\ub9ac\uc2a4: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nRestoration incomplete. Retry with Battery Saving off."

    const-string v1, "\n\ubcf5\uc6d0\uc774 \ub05d\ub098\uc9c0 \uc54a\uc558\uc2b5\ub2c8\ub2e4. \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub044\uace0 \ub2e4\uc2dc \uc2dc\ub3c4\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\nTable "

    const-string v1, "\n\ud14c\uc774\ube14 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " (not "

    const-string v1, " (\uc544\ub2d8: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " selected"

    const-string v1, "\uac1c \uc120\ud0dd\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " \u00b7 Original: "

    const-string v1, " \u00b7 \uc6d0\ub798 \uac12: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " \u00b7 Power level "

    const-string v1, " \u00b7 \uc804\ub825 \ub2e8\uacc4 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " \u00b7 Requested: "

    const-string v1, " \u00b7 \uc694\uccad \uac12: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, " \u00b7 minimum "

    const-string v1, " \u00b7 \ucd5c\uc18c "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "\"reduce transparency\" is on in the accessibility settings"

    const-string v1, "\uc811\uadfc\uc131 \uc124\uc815\uc5d0\uc11c \"\ud22c\uba85\ub3c4 \uc904\uc774\uae30\"\uac00 \ucf1c\uc838 \uc788\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "% battery"

    const-string v1, "% \ubc30\ud130\ub9ac"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "% remaining"

    const-string v1, "% \ub0a8\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, ". Keep the device powered\u2026"

    const-string v1, ". \uae30\uae30 \uc804\uc6d0\uc744 \ucf1c \ub454 \ucc44\ub85c \uae30\ub2e4\ub9ac\uc138\uc694\u2026"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, ". Refresh status before any further action."

    const-string v1, ". \ub2e4\ub978 \uc791\uc5c5\uc744 \ud558\uae30 \uc804\uc5d0 \uc0c1\ud0dc\ub97c \uc0c8\ub85c \uace0\uce58\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, ". Rollback export: "

    const-string v1, ". \ub864\ubc31 \ub0b4\ubcf4\ub0b4\uae30: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, ". Your tuning profile stays saved."

    const-string v1, ". \ud29c\ub2dd \ud504\ub85c\ud544\uc740 \uadf8\ub300\ub85c \uc800\uc7a5\ub3fc \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "; requested bucket is not effective"

    const-string v1, "; \uc694\uccad\ud55c \ub300\uae30 \ubc84\ud0b7\uc774 \uc801\uc6a9\ub418\uc9c0 \uc54a\uc558\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "ACD cell (decimal/0x hex, or none)"

    const-string v1, "ACD \uc140 (10\uc9c4\uc218/0x 16\uc9c4\uc218, \ub610\ub294 none)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "ACD changed; "

    const-string v1, "ACD \ubcc0\uacbd\ub428; "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Accessibility apps"

    const-string v1, "\uc811\uadfc\uc131 \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Accessibility \u2014 hide settings and service lists"

    const-string v1, "\uc811\uadfc\uc131 \u2014 \uc124\uc815\uacfc \uc11c\ube44\uc2a4 \ubaa9\ub85d \uc228\uae30\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Action"

    const-string v1, "\ub3d9\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Action unavailable"

    const-string v1, "\uc0ac\uc6a9\ud560 \uc218 \uc5c6\ub294 \ub3d9\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Action: "

    const-string v1, "\ub3d9\uc791: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Active"

    const-string v1, "\ud65c\uc131"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Active (10)"

    const-string v1, "\ud65c\uc131 (10)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Add power level"

    const-string v1, "\uc804\ub825 \ub2e8\uacc4 \ucd94\uac00"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Added power level. "

    const-string v1, "\uc804\ub825 \ub2e8\uacc4\ub97c \ucd94\uac00\ud588\uc2b5\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Advanced GPU Tuning"

    const-string v1, "\uace0\uae09 GPU \ud29c\ub2dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Advanced GPU Tuning (Konabess)"

    const-string v1, "\uace0\uae09 GPU \ud29c\ub2dd (KonaBess)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Aggressive restrictions cover all eligible user and system apps, including Play services and both stores. Selected apps below are additional targets, not exceptions."

    const-string v1, "\uac15\ub825 \uc81c\ud55c\uc740 Play \uc11c\ube44\uc2a4\uc640 \ub450 \uc2a4\ud1a0\uc5b4\ub97c \ud3ec\ud568\ud574 \ub300\uc0c1\uc774 \ub418\ub294 \ubaa8\ub4e0 \uc0ac\uc6a9\uc790\u00b7\uc2dc\uc2a4\ud15c \uc571\uc5d0 \uc801\uc6a9\ub429\ub2c8\ub2e4. \uc544\ub798\uc5d0\uc11c \uc120\ud0dd\ud55c \uc571\uc740 \uc608\uc678\uac00 \uc544\ub2c8\ub77c \ucd94\uac00 \ub300\uc0c1\uc785\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Android default"

    const-string v1, "Android \uae30\ubcf8\uac12"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Animator duration"

    const-string v1, "\uc560\ub2c8\uba54\uc774\ud130 \uae38\uc774"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "App"

    const-string v1, "\uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Apply"

    const-string v1, "\uc801\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Apply GPU table"

    const-string v1, "GPU \ud14c\uc774\ube14 \uc801\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Apply custom restrictions?"

    const-string v1, "\uc0ac\uc6a9\uc790 \uc9c0\uc815 \uc81c\ud55c\uc744 \uc801\uc6a9\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Apply trial"

    const-string v1, "\uc2dc\ud5d8 \uc801\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Assign one action to each tile, then add it to Quick Settings. Hold a tile to edit it."

    const-string v1, "\ud0c0\uc77c\ub9c8\ub2e4 \ub3d9\uc791\uc744 \ud558\ub098\uc529 \uc9c0\uc815\ud55c \ub4a4 \ube60\ub978 \uc124\uc815\uc5d0 \ucd94\uac00\ud558\uc138\uc694. \ud0c0\uc77c\uc744 \uae38\uac8c \ub204\ub974\uba74 \ud3b8\uc9d1\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Automatic"

    const-string v1, "\uc790\ub3d9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Back up profile"

    const-string v1, "\ud504\ub85c\ud544 \ubc31\uc5c5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Backups contain your choices, not device paths or original system values. Restore validates the file and leaves Battery Saving off until you enable it."

    const-string v1, "\ubc31\uc5c5\uc5d0\ub294 \uc120\ud0dd\ud55c \uc124\uc815\ub9cc \ub4e4\uc5b4\uac00\uba70 \uae30\uae30 \uacbd\ub85c\ub098 \uc6d0\ub798 \uc2dc\uc2a4\ud15c \uac12\uc740 \ub4e4\uc5b4\uac00\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4. \ubcf5\uc6d0\ud558\uba74 \ud30c\uc77c\uc744 \uac80\uc0ac\ud558\uace0, \uc9c1\uc811 \ucf1c\uae30 \uc804\uae4c\uc9c0 \ubc30\ud130\ub9ac \uc808\uc57d\uc740 \uaebc\uc9c4 \uc0c1\ud0dc\ub85c \ub461\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Balanced preserves kernel and memory defaults and reports freezer state. Efficiency selects an advertised CPU ceiling near 85% of the original fastest-cluster limit; battery benefit needs measurement. Refresh-rate limiting stays optional. NOSLEN reproduces the module\'s intended settings. Stingy uses the lowest usable clocks and refresh rate, restricts user and non-essential system apps including Play services and both app stores, disables auto-sync, dims the screen, removes animations and enables dark mode. Severe performance and background-function loss are intentional."

    const-string v1, "Balanced\ub294 \ucee4\ub110\uacfc \uba54\ubaa8\ub9ac \uae30\ubcf8\uac12\uc744 \uc720\uc9c0\ud558\uace0 \ud504\ub9ac\uc800 \uc0c1\ud0dc\ub97c \ubcf4\uc5ec\uc90d\ub2c8\ub2e4. Efficiency\ub294 \uac00\uc7a5 \ube60\ub978 \ud074\ub7ec\uc2a4\ud130 \uc6d0\ub798 \ud55c\ub3c4\uc758 \uc57d 85%\uc5d0 \ud574\ub2f9\ud558\ub294 CPU \uc0c1\ud55c\uc744 \uace0\ub974\uba70, \ubc30\ud130\ub9ac \ud6a8\uacfc\ub294 \uc9c1\uc811 \uce21\uc815\ud574\ubd10\uc57c \ud569\ub2c8\ub2e4. \uc8fc\uc0ac\uc728 \uc81c\ud55c\uc740 \uc120\ud0dd \uc0ac\ud56d\uc785\ub2c8\ub2e4. NOSLEN\uc740 \uc6d0\ub798 \ubaa8\ub4c8\uc774 \uc758\ub3c4\ud55c \uc124\uc815\uc744 \uadf8\ub300\ub85c \uc801\uc6a9\ud569\ub2c8\ub2e4. Stingy\ub294 \uc0ac\uc6a9\ud560 \uc218 \uc788\ub294 \uac00\uc7a5 \ub0ae\uc740 \ud074\ub7ed\uacfc \uc8fc\uc0ac\uc728\uc744 \uc4f0\uace0, Play \uc11c\ube44\uc2a4\uc640 \ub450 \uc571 \uc2a4\ud1a0\uc5b4\ub97c \ud3ec\ud568\ud55c \uc0ac\uc6a9\uc790 \uc571\uacfc \ud544\uc218\uac00 \uc544\ub2cc \uc2dc\uc2a4\ud15c \uc571\uc744 \uc81c\ud55c\ud558\uba70, \uc790\ub3d9 \ub3d9\uae30\ud654\ub97c \ub044\uace0 \ud654\uba74\uc744 \uc5b4\ub461\uac8c \ud558\uace0 \uc560\ub2c8\uba54\uc774\uc158\uc744 \uc5c6\uc560\uace0 \ub2e4\ud06c \ubaa8\ub4dc\ub97c \ucf2d\ub2c8\ub2e4. \uc131\ub2a5\uacfc \ubc31\uadf8\ub77c\uc6b4\ub4dc \uae30\ub2a5\uc774 \ud06c\uac8c \ub5a8\uc5b4\uc9c0\ub294 \uac83\uc740 \uc758\ub3c4\ub41c \ub3d9\uc791\uc785\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Battery Saving"

    const-string v1, "\ubc30\ud130\ub9ac \uc808\uc57d"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bluetooth device"

    const-string v1, "\ube14\ub8e8\ud22c\uc2a4 \uae30\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Boot into OrangeFox using the device\'s recovery procedure. Mount Cache. Flash /cache/unica-gpu/rollback.zip, or flash the saved rollback ZIP from USB/PC storage. It verifies and restores the exact pre-trial vendor_boot image. Reboot manually after success. Keep a matching full ROM available if recovery restoration fails. Never use this ZIP after changing firmware."

    const-string v1, "\uae30\uae30\uc758 \ub9ac\ucee4\ubc84\ub9ac \uc9c4\uc785 \ubc29\ubc95\uc73c\ub85c OrangeFox\uc5d0 \ub4e4\uc5b4\uac00\uc138\uc694. Cache\ub97c \ub9c8\uc6b4\ud2b8\ud558\uace0 /cache/unica-gpu/rollback.zip\uc744 \ud50c\ub798\uc2dc\ud558\uac70\ub098, USB/PC\uc5d0 \uc800\uc7a5\ud574 \ub454 \ub864\ubc31 ZIP\uc744 \ud50c\ub798\uc2dc\ud558\uc138\uc694. \uc2dc\ud5d8 \uc801\uc6a9 \uc804\uc758 vendor_boot \uc774\ubbf8\uc9c0\ub97c \uac80\uc99d\ud55c \ub4a4 \uadf8\ub300\ub85c \ubcf5\uc6d0\ud569\ub2c8\ub2e4. \uc131\uacf5\ud558\uba74 \uc9c1\uc811 \uc7ac\ubd80\ud305\ud558\uc138\uc694. \ub9ac\ucee4\ubc84\ub9ac \ubcf5\uc6d0\uc774 \uc2e4\ud328\ud560 \uacbd\uc6b0\ub97c \ub300\ube44\ud574 \uac19\uc740 \ubc84\uc804\uc758 \uc804\uccb4 \ub86c\uc744 \uc900\ube44\ud574 \ub450\uc138\uc694. \ud38c\uc6e8\uc5b4\ub97c \ubc14\uafbc \ub4a4\uc5d0\ub294 \uc774 ZIP\uc744 \uc808\ub300 \uc0ac\uc6a9\ud558\uc9c0 \ub9c8\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Both tables are stored in firmware. The driver chooses the active table by chip/SKU; choosing a table here only chooses which draft to edit. Up to 15 entries per table, within the original FDT space. RPMh requests are mapped to available command-DB corners, not millivolts. Red marks values outside stock. None of these settings are a stability guarantee."

    const-string v1, "\ub450 \ud14c\uc774\ube14 \ubaa8\ub450 \ud38c\uc6e8\uc5b4\uc5d0 \uc800\uc7a5\ub3fc \uc788\uc2b5\ub2c8\ub2e4. \uc2e4\uc81c\ub85c \uc4f0\uc77c \ud14c\uc774\ube14\uc740 \ub4dc\ub77c\uc774\ubc84\uac00 \uce69/SKU\uc5d0 \ub530\ub77c \uace0\ub974\uba70, \uc5ec\uae30\uc11c \ud14c\uc774\ube14\uc744 \uace0\ub974\ub294 \uac74 \uc5b4\ub5a4 \ucd08\uc548\uc744 \ud3b8\uc9d1\ud560\uc9c0\ub9cc \uc815\ud569\ub2c8\ub2e4. \ud14c\uc774\ube14\ub9c8\ub2e4 \uc6d0\ub798 FDT \uacf5\uac04 \uc548\uc5d0\uc11c \ucd5c\ub300 15\uac1c \ud56d\ubaa9\uae4c\uc9c0 \ub123\uc744 \uc218 \uc788\uc2b5\ub2c8\ub2e4. RPMh \uc694\uccad \uac12\uc740 \ubc00\ub9ac\ubcfc\ud2b8\uac00 \uc544\ub2c8\ub77c command-DB\uc758 \uc0ac\uc6a9 \uac00\ub2a5\ud55c \ucf54\ub108\ub85c \ub300\uc751\ub429\ub2c8\ub2e4. \ube68\uac04\uc0c9\uc740 \uc21c\uc815 \ubc94\uc704\ub97c \ubc97\uc5b4\ub09c \uac12\uc785\ub2c8\ub2e4. \uc5b4\ub5a4 \uc124\uc815\ub3c4 \uc548\uc815\uc131\uc744 \ubcf4\uc7a5\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bus "

    const-string v1, "\ubc84\uc2a4 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bus and ACD \u00b7 level "

    const-string v1, "\ubc84\uc2a4 \ubc0f ACD \u00b7 \ub2e8\uacc4 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bus frequency index"

    const-string v1, "\ubc84\uc2a4 \uc8fc\ud30c\uc218 \uc778\ub371\uc2a4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bus maximum index"

    const-string v1, "\ubc84\uc2a4 \ucd5c\ub300 \uc778\ub371\uc2a4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Bus minimum index"

    const-string v1, "\ubc84\uc2a4 \ucd5c\uc18c \uc778\ub371\uc2a4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "CPU ceiling \u00b7 "

    const-string v1, "CPU \uc0c1\ud55c \u00b7 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cached-process effective limit unavailable"

    const-string v1, "\uce90\uc2dc \ud504\ub85c\uc138\uc2a4 \uc2e4\uc81c \ud55c\ub3c4\ub97c \ud655\uc778\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Camera"

    const-string v1, "\uce74\uba54\ub77c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Camera & microphone in use"

    const-string v1, "\uce74\uba54\ub77c\u00b7\ub9c8\uc774\ud06c \uc0ac\uc6a9 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Camera in use"

    const-string v1, "\uce74\uba54\ub77c \uc0ac\uc6a9 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cancel"

    const-string v1, "\ucde8\uc18c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot add level"

    const-string v1, "\ub2e8\uacc4\ub97c \ucd94\uac00\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot apply"

    const-string v1, "\uc801\uc6a9\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot enumerate background apps: "

    const-string v1, "\ubc31\uadf8\ub77c\uc6b4\ub4dc \uc571 \ubaa9\ub85d\uc744 \ubd88\ub7ec\uc62c \uc218 \uc5c6\uc74c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot initialize tuning profile: "

    const-string v1, "\ud29c\ub2dd \ud504\ub85c\ud544\uc744 \ucd08\uae30\ud654\ud560 \uc218 \uc5c6\uc74c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot load values"

    const-string v1, "\uac12\uc744 \ubd88\ub7ec\uc62c \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot remove level"

    const-string v1, "\ub2e8\uacc4\ub97c \uc0ad\uc81c\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot save island settings. The rules or app list may be too large."

    const-string v1, "\uc544\uc77c\ub79c\ub4dc \uc124\uc815\uc744 \uc800\uc7a5\ud560 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4. \uaddc\uce59\uc774\ub098 \uc571 \ubaa9\ub85d\uc774 \ub108\ubb34 \ud074 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot save profile"

    const-string v1, "\ud504\ub85c\ud544\uc744 \uc800\uc7a5\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Cannot save voltage request"

    const-string v1, "\uc804\uc555 \uc694\uccad \uac12\uc744 \uc800\uc7a5\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Changes take effect after reboot. Unsuitable values can cause freezes or prevent booting. Keep your recovery rollback available."

    const-string v1, "\ubcc0\uacbd \uc0ac\ud56d\uc740 \uc7ac\ubd80\ud305 \ud6c4 \uc801\uc6a9\ub429\ub2c8\ub2e4. \ub9de\uc9c0 \uc54a\ub294 \uac12\uc740 \uba48\ucda4\uc774\ub098 \ubd80\ud305 \ubd88\uac00\ub97c \uc77c\uc73c\ud0ac \uc218 \uc788\uc2b5\ub2c8\ub2e4. \ub9ac\ucee4\ubc84\ub9ac \ub864\ubc31\uc744 \uc900\ube44\ud574 \ub450\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Charging"

    const-string v1, "\ucda9\uc804 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose Exempted App"

    const-string v1, "\uc608\uc678 \uc571 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose a downloaded update and check compatibility"

    const-string v1, "\ub2e4\uc6b4\ub85c\ub4dc\ud55c \uc5c5\ub370\uc774\ud2b8\ub97c \uace8\ub77c \ud638\ud658\uc131\uc744 \ud655\uc778\ud558\uc138\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose an action"

    const-string v1, "\ub3d9\uc791 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose an app shortcut"

    const-string v1, "\uc571 \ubc14\ub85c\uac00\uae30 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose an installed app"

    const-string v1, "\uc124\uce58\ub41c \uc571 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose apps for full restrictions"

    const-string v1, "\uc804\uccb4 \uc81c\ud55c\ud560 \uc571 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose apps for standby only"

    const-string v1, "\ub300\uae30\ub9cc \uc81c\ud55c\ud560 \uc571 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose exemptions to remove"

    const-string v1, "\uc0ad\uc81c\ud560 \uc608\uc678 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Choose target"

    const-string v1, "\ub300\uc0c1 \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Clear this tile\'s action and label?"

    const-string v1, "\uc774 \ud0c0\uc77c\uc758 \ub3d9\uc791\uacfc \uc774\ub984\uc744 \uc9c0\uc6b8\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Compatible firmware. Backup: "

    const-string v1, "\ud638\ud658\ub418\ub294 \ud38c\uc6e8\uc5b4\uc785\ub2c8\ub2e4. \ubc31\uc5c5: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Configuration saved. You can also add the tile using Quick Settings \u2192 Edit."

    const-string v1, "\uc124\uc815\uc744 \uc800\uc7a5\ud588\uc2b5\ub2c8\ub2e4. \ube60\ub978 \uc124\uc815 \u2192 \ud3b8\uc9d1\uc5d0\uc11c\ub3c4 \ud0c0\uc77c\uc744 \ucd94\uac00\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Connected"

    const-string v1, "\uc5f0\uacb0\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Connected \u00b7 "

    const-string v1, "\uc5f0\uacb0\ub428 \u00b7 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Continue"

    const-string v1, "\uacc4\uc18d"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Controls"

    const-string v1, "\uc81c\uc5b4 \ud56d\ubaa9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Copied"

    const-string v1, "\ubcf5\uc0ac\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Copy"

    const-string v1, "\ubcf5\uc0ac"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not back up HMA config"

    const-string v1, "HMA \uc124\uc815\uc744 \ubc31\uc5c5\ud558\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not complete: "

    const-string v1, "\uc644\ub8cc\ud558\uc9c0 \ubabb\ud568: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not load installed apps."

    const-string v1, "\uc124\uce58\ub41c \uc571\uc744 \ubd88\ub7ec\uc624\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not load unknown installed apps."

    const-string v1, "\ucd9c\ucc98 \ubd88\uba85 \uc124\uce58 \uc571\uc744 \ubd88\ub7ec\uc624\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not open file picker"

    const-string v1, "\ud30c\uc77c \uc120\ud0dd\uae30\ub97c \uc5f4\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not restore HMA config"

    const-string v1, "HMA \uc124\uc815\uc744 \ubcf5\uc6d0\ud558\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Could not save HMA settings"

    const-string v1, "HMA \uc124\uc815\uc744 \uc800\uc7a5\ud558\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Create backup"

    const-string v1, "\ubc31\uc5c5 \ub9cc\ub4e4\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Create backup for current ROM?"

    const-string v1, "\ud604\uc7ac \ub86c\uc758 \ubc31\uc5c5\uc744 \ub9cc\ub4e4\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Current: "

    const-string v1, "\ud604\uc7ac: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Custom ROM apps"

    const-string v1, "\ucee4\uc2a4\ud140 \ub86c \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Custom request"

    const-string v1, "\uc0ac\uc6a9\uc790 \uc9c0\uc815 \uc694\uccad"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Custom voltage request"

    const-string v1, "\uc0ac\uc6a9\uc790 \uc9c0\uc815 \uc804\uc555 \uc694\uccad"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Dark"

    const-string v1, "\ub2e4\ud06c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Detector / checker apps"

    const-string v1, "\ud0d0\uc9c0 / \uac80\uc0ac \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Developer options \u2014 hide ADB, developer and mock-location settings"

    const-string v1, "\uac1c\ubc1c\uc790 \uc635\uc158 \u2014 ADB, \uac1c\ubc1c\uc790, \ubaa8\uc758 \uc704\uce58 \uc124\uc815 \uc228\uae30\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Device status"

    const-string v1, "\uae30\uae30 \uc0c1\ud0dc"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Disable selected apps completely, not just their exemptions. Their services and features will stop. Calls, alarms, notifications, accounts and connectivity can fail. Protected recovery apps cannot be selected. Save and apply will ask before restarting after successful changes. Deselect or turn Battery Saving off to restore saved app states."

    const-string v1, "\uc608\uc678\ub9cc \uc5c6\uc560\ub294 \uac8c \uc544\ub2c8\ub77c \uc120\ud0dd\ud55c \uc571\uc744 \uc644\uc804\ud788 \uc0ac\uc6a9 \uc911\uc9c0\ud569\ub2c8\ub2e4. \ud574\ub2f9 \uc571\uc758 \uc11c\ube44\uc2a4\uc640 \uae30\ub2a5\uc774 \uba48\ucda5\ub2c8\ub2e4. \uc804\ud654, \uc54c\ub78c, \uc54c\ub9bc, \uacc4\uc815, \uc5f0\uacb0\uc774 \uc2e4\ud328\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \ubcf5\uad6c\uc6a9\uc73c\ub85c \ubcf4\ud638\ub41c \uc571\uc740 \uc120\ud0dd\ud560 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4. \ubcc0\uacbd\uc774 \uc131\uacf5\ud558\uba74 \uc800\uc7a5 \ubc0f \uc801\uc6a9\uc5d0\uc11c \ub2e4\uc2dc \uc2dc\uc791\ud558\uae30 \uc804\uc5d0 \ubb3b\uc2b5\ub2c8\ub2e4. \uc120\ud0dd\uc744 \ud574\uc81c\ud558\uac70\ub098 \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub044\uba74 \uc800\uc7a5\ub41c \uc571 \uc0c1\ud0dc\ub85c \ub3cc\uc544\uac11\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Display modes unavailable; refresh-rate control disabled"

    const-string v1, "\ub514\uc2a4\ud50c\ub808\uc774 \ubaa8\ub4dc\ub97c \uc4f8 \uc218 \uc5c6\uc5b4 \uc8fc\uc0ac\uc728 \uc81c\uc5b4\ub97c \uaed0\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Do Not Disturb"

    const-string v1, "\ubc29\ud574 \uae08\uc9c0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Download latest OTA"

    const-string v1, "\ucd5c\uc2e0 OTA \ub2e4\uc6b4\ub85c\ub4dc"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Download the latest OTA from the folder, then return here and select its ZIP."

    const-string v1, "\ud3f4\ub354\uc5d0\uc11c \ucd5c\uc2e0 OTA\ub97c \ub2e4\uc6b4\ub85c\ub4dc\ud55c \ub4a4 \uc5ec\uae30\ub85c \ub3cc\uc544\uc640 ZIP\uc744 \uc120\ud0dd\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Doze exemptions"

    const-string v1, "Doze \uc608\uc678"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Draft level added"

    const-string v1, "\ucd08\uc548 \ub2e8\uacc4 \ucd94\uac00\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Edit GPU table"

    const-string v1, "GPU \ud14c\uc774\ube14 \ud3b8\uc9d1"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Enable All"

    const-string v1, "\ubaa8\ub450 \ucf1c\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Enable Battery Saving"

    const-string v1, "\ubc30\ud130\ub9ac \uc808\uc57d \ucf1c\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Encryption Spoof"

    const-string v1, "\uc554\ud638\ud654 \uc704\uc7a5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Exempted (5)"

    const-string v1, "\uc608\uc678 (5)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

.method private static fill1(Ljava/util/HashMap;)V
    .locals 2

    const-string v0, "Exempted App"

    const-string v1, "\uc608\uc678 \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Expected "

    const-string v1, "\ud544\uc694\ud55c \uac12 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Expected whole number: "

    const-string v1, "\uc815\uc218\uac00 \ud544\uc694\ud568: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Experimental settings"

    const-string v1, "\uc2e4\ud5d8\uc801 \uc124\uc815"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Experimental. These choices remove supplementary groups from selected apps at their next process start. Network or storage access may stop working and apps may crash. Restart selected apps after changing this setting."

    const-string v1, "\uc2e4\ud5d8\uc801 \uae30\ub2a5\uc785\ub2c8\ub2e4. \uc120\ud0dd\ud55c \uc571\uc774 \ub2e4\uc74c\uc5d0 \ud504\ub85c\uc138\uc2a4\ub97c \uc2dc\uc791\ud560 \ub54c \ubcf4\uc870 \uadf8\ub8f9\uc744 \uc81c\uac70\ud569\ub2c8\ub2e4. \ub124\ud2b8\uc6cc\ud06c\ub098 \uc800\uc7a5\uc18c \uc811\uadfc\uc774 \uc548 \ub418\uac70\ub098 \uc571\uc774 \uc885\ub8cc\ub420 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc774 \uc124\uc815\uc744 \ubc14\uafbc \ub4a4\uc5d0\ub294 \uc120\ud0dd\ud55c \uc571\uc744 \ub2e4\uc2dc \uc2dc\uc791\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Fast charging"

    const-string v1, "\uace0\uc18d \ucda9\uc804"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "File picker unavailable"

    const-string v1, "\ud30c\uc77c \uc120\ud0dd\uae30\ub97c \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Final GPU row bypasses the driver bus clamp: bus maximum must be 0\u20139 (got "

    const-string v1, "\ub9c8\uc9c0\ub9c9 GPU \ud589\uc740 \ub4dc\ub77c\uc774\ubc84 \ubc84\uc2a4 \uc81c\ud55c\uc744 \uac70\uce58\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4: \ubc84\uc2a4 \ucd5c\ub300\uac12\uc740 0\u20139\uc5ec\uc57c \ud569\ub2c8\ub2e4 (\uc785\ub825\uac12 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Flashlight"

    const-string v1, "\uc190\uc804\ub4f1"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Frequent (30)"

    const-string v1, "\uc790\uc8fc \uc0ac\uc6a9 (30)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Full background restrictions: "

    const-string v1, "\ubc31\uadf8\ub77c\uc6b4\ub4dc \uc804\uccb4 \uc81c\ud55c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Full restrictions: choose Play Store, Play services, Galaxy Store or other apps. Applies restricted standby, background execution limits, metered background data blocking and removal of user Doze exemptions. Automatic account sync and Data Saver are separate controls above. Unmetered Wi-Fi is not fully blocked."

    const-string v1, "\uc804\uccb4 \uc81c\ud55c: Play \uc2a4\ud1a0\uc5b4, Play \uc11c\ube44\uc2a4, Galaxy Store \ub4f1\uc758 \uc571\uc744 \uace0\ub974\uc138\uc694. \ub300\uae30 \uc81c\ud55c, \ubc31\uadf8\ub77c\uc6b4\ub4dc \uc2e4\ud589 \uc81c\ud55c, \uc885\ub7c9\uc81c \ubc31\uadf8\ub77c\uc6b4\ub4dc \ub370\uc774\ud130 \ucc28\ub2e8, \uc0ac\uc6a9\uc790 Doze \uc608\uc678 \uc0ad\uc81c\uac00 \uc801\uc6a9\ub429\ub2c8\ub2e4. \uacc4\uc815 \uc790\ub3d9 \ub3d9\uae30\ud654\uc640 \ub370\uc774\ud130 \uc808\uc57d \ubaa8\ub4dc\ub294 \uc704\uc5d0 \uc788\ub294 \ubcc4\ub3c4 \ud56d\ubaa9\uc785\ub2c8\ub2e4. \ube44\uc885\ub7c9\uc81c Wi-Fi\ub294 \uc644\uc804\ud788 \ucc28\ub2e8\ub418\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU frequency (MHz)"

    const-string v1, "GPU \uc8fc\ud30c\uc218 (MHz)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU frequency and voltage tuning for S23 Ultra."

    const-string v1, "S23 \uc6b8\ud2b8\ub77c\uc6a9 GPU \uc8fc\ud30c\uc218\u00b7\uc804\uc555 \ud29c\ub2dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU image"

    const-string v1, "GPU \uc774\ubbf8\uc9c0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU operation failed"

    const-string v1, "GPU \uc791\uc5c5 \uc2e4\ud328"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU tables"

    const-string v1, "GPU \ud14c\uc774\ube14"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "GPU tuning"

    const-string v1, "GPU \ud29c\ub2dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "HMA config backed up"

    const-string v1, "HMA \uc124\uc815\uc744 \ubc31\uc5c5\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "HMA config restored"

    const-string v1, "HMA \uc124\uc815\uc744 \ubcf5\uc6d0\ud588\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "INET (3003) \u2014 removes network access; apps may crash"

    const-string v1, "INET (3003) \u2014 \ub124\ud2b8\uc6cc\ud06c \uc811\uadfc\uc744 \ub9c9\uc74c; \uc571\uc774 \uc885\ub8cc\ub420 \uc218 \uc788\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Icon"

    const-string v1, "\uc544\uc774\ucf58"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Icon: "

    const-string v1, "\uc544\uc774\ucf58: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "If Android cannot start"

    const-string v1, "Android\uac00 \uc2dc\uc791\ub418\uc9c0 \uc54a\uc744 \ub54c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Index from 0 to "

    const-string v1, "\uc778\ub371\uc2a4 \ubc94\uc704: 0 ~ "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Initial power level"

    const-string v1, "\ucd08\uae30 \uc804\ub825 \ub2e8\uacc4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Input method \u2014 report Gboard and Google TTS; filter keyboard lists"

    const-string v1, "\uc785\ub825 \ubc29\ubc95 \u2014 Gboard\uc640 Google TTS\ub85c \ubcf4\uace0\ud558\uace0 \ud0a4\ubcf4\ub4dc \ubaa9\ub85d \ud544\ud130\ub9c1"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Inspired by libxzr/KonaBess. Both Samsung GPU tables, within the inspected FDT space. Nothing applies or reboots automatically."

    const-string v1, "libxzr/KonaBess\ub97c \ucc38\uace0\ud588\uc2b5\ub2c8\ub2e4. \ud655\uc778\ub41c FDT \uacf5\uac04 \uc548\uc5d0\uc11c \uc0bc\uc131 GPU \ud14c\uc774\ube14 \ub450 \uac1c\ub97c \ubaa8\ub450 \ub2e4\ub8f9\ub2c8\ub2e4. \uc790\ub3d9\uc73c\ub85c \uc801\uc6a9\ub418\uac70\ub098 \uc7ac\ubd80\ud305\ub418\ub294 \uac83\uc740 \uc5c6\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Install"

    const-string v1, "\uc124\uce58"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Install OTA update?"

    const-string v1, "OTA \uc5c5\ub370\uc774\ud2b8\ub97c \uc124\uce58\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Install and reboot"

    const-string v1, "\uc124\uce58 \ud6c4 \uc7ac\ubd80\ud305"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Installed software"

    const-string v1, "\uc124\uce58\ub41c \uc18c\ud504\ud2b8\uc6e8\uc5b4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Invalid GPU frequency, RPMh request, bus ordering or ACD cell at level "

    const-string v1, "GPU \uc8fc\ud30c\uc218, RPMh \uc694\uccad, \ubc84\uc2a4 \uc21c\uc11c \ub610\ub294 ACD \uc140\uc774 \uc798\ubabb\ub41c \ub2e8\uacc4: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Invalid profile text: "

    const-string v1, "\uc798\ubabb\ub41c \ud504\ub85c\ud544 \ub0b4\uc6a9: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Invalid value for "

    const-string v1, "\uc798\ubabb\ub41c \uac12: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Keep the rollback ZIP and recovery available. Only reboot after Apply or Restore reports success."

    const-string v1, "\ub864\ubc31 ZIP\uacfc \ub9ac\ucee4\ubc84\ub9ac\ub97c \uc900\ube44\ud574 \ub450\uc138\uc694. \uc801\uc6a9\uc774\ub098 \ubcf5\uc6d0\uc774 \uc131\uacf5\ud588\ub2e4\uace0 \ub098\uc628 \ub4a4\uc5d0\ub9cc \uc7ac\ubd80\ud305\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Kernel controls unavailable: "

    const-string v1, "\ucee4\ub110 \uc81c\uc5b4\ub97c \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc74c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "LSPosed / Xposed modules"

    const-string v1, "LSPosed / Xposed \ubaa8\ub4c8"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Last installation: "

    const-string v1, "\ub9c8\uc9c0\ub9c9 \uc124\uce58: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Level "

    const-string v1, "\ub2e8\uacc4 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Light"

    const-string v1, "\ub77c\uc774\ud2b8"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Load imported tuning profile?"

    const-string v1, "\uac00\uc838\uc628 \ud29c\ub2dd \ud504\ub85c\ud544\uc744 \ubd88\ub7ec\uc62c\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Load profile"

    const-string v1, "\ud504\ub85c\ud544 \ubd88\ub7ec\uc624\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Load values"

    const-string v1, "\uac12 \ubd88\ub7ec\uc624\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Loading apps\u2026"

    const-string v1, "\uc571 \ubd88\ub7ec\uc624\ub294 \uc911\u2026"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Location in use"

    const-string v1, "\uc704\uce58 \uc0ac\uc6a9 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Low battery"

    const-string v1, "\ubc30\ud130\ub9ac \ubd80\uc871"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "MEDIA_RW (1023) \u2014 media write access"

    const-string v1, "MEDIA_RW (1023) \u2014 \ubbf8\ub514\uc5b4 \uc4f0\uae30 \uad8c\ud55c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Microphone in use"

    const-string v1, "\ub9c8\uc774\ud06c \uc0ac\uc6a9 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Missing or malformed "

    const-string v1, "\uc5c6\uac70\ub098 \ud615\uc2dd\uc774 \uc798\ubabb\ub428: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Missing profile field: "

    const-string v1, "\ud504\ub85c\ud544 \ud56d\ubaa9 \uc5c6\uc74c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "My GPU profile"

    const-string v1, "\ub0b4 GPU \ud504\ub85c\ud544"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "NOSLEN disables Wi-Fi runtime suspend and PCIe link power saving, disables Wi-Fi wakeup, sets swappiness to 60 and cached processes to 32, and restricts three Samsung apps. It may increase drain or delay background communication. Unsupported controls will be reported."

    const-string v1, "NOSLEN\uc740 Wi-Fi \ub7f0\ud0c0\uc784 \uc808\uc804\uacfc PCIe \ub9c1\ud06c \uc808\uc804\uc744 \ub044\uace0, Wi-Fi \uae68\uc6b0\uae30\ub97c \ub044\uace0, swappiness\ub97c 60, \uce90\uc2dc \ud504\ub85c\uc138\uc2a4\ub97c 32\ub85c \ub9de\ucd94\uace0, \uc0bc\uc131 \uc571 3\uac1c\ub97c \uc81c\ud55c\ud569\ub2c8\ub2e4. \ubc30\ud130\ub9ac \uc18c\ubaa8\uac00 \ub298\uac70\ub098 \ubc31\uadf8\ub77c\uc6b4\ub4dc \ud1b5\uc2e0\uc774 \ub2a6\uc5b4\uc9c8 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc9c0\uc6d0\ub418\uc9c0 \uc54a\ub294 \ud56d\ubaa9\uc740 \ub530\ub85c \uc54c\ub824\uc90d\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "NOSLEN profile"

    const-string v1, "NOSLEN \ud504\ub85c\ud544"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Navigate up"

    const-string v1, "\uc704\ub85c \uc774\ub3d9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Never (50)"

    const-string v1, "\uc0ac\uc6a9 \uc548 \ud568 (50)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "No app available to open this link."

    const-string v1, "\uc774 \ub9c1\ud06c\ub97c \uc5f4 \uc218 \uc788\ub294 \uc571\uc774 \uc5c6\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "No app can open the download folder. Install a browser, or select an OTA ZIP downloaded elsewhere."

    const-string v1, "\ub2e4\uc6b4\ub85c\ub4dc \ud3f4\ub354\ub97c \uc5f4 \uc218 \uc788\ub294 \uc571\uc774 \uc5c6\uc2b5\ub2c8\ub2e4. \ube0c\ub77c\uc6b0\uc800\ub97c \uc124\uce58\ud558\uac70\ub098 \ub2e4\ub978 \uacf3\uc5d0\uc11c \ubc1b\uc740 OTA ZIP\uc744 \uc120\ud0dd\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "No apps selected"

    const-string v1, "\uc120\ud0dd\ud55c \uc571 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "No apps selected for disabling"

    const-string v1, "\uc0ac\uc6a9 \uc911\uc9c0\ud560 \uc571\uc744 \uc120\ud0dd\ud558\uc9c0 \uc54a\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "No saved profile"

    const-string v1, "\uc800\uc7a5\ub41c \ud504\ub85c\ud544 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Not configured"

    const-string v1, "\uc124\uc815 \uc548 \ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "OTA Update"

    const-string v1, "OTA \uc5c5\ub370\uc774\ud2b8"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "OTA verified. Ready to install."

    const-string v1, "OTA \uac80\uc99d \uc644\ub8cc. \uc124\uce58\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Off"

    const-string v1, "\uaebc\uc9d0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "One tap runs the selected action. Changes take effect after Save."

    const-string v1, "\ud55c \ubc88 \ub204\ub974\uba74 \uc120\ud0dd\ud55c \ub3d9\uc791\uc744 \uc2e4\ud589\ud569\ub2c8\ub2e4. \ubcc0\uacbd \uc0ac\ud56d\uc740 \uc800\uc7a5 \ud6c4 \uc801\uc6a9\ub429\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Only select apps whose background work you can limit. Restricting messaging, alarms, VPN, wearables or Samsung feature providers can break expected behavior. No apps are selected by Balanced or Efficiency."

    const-string v1, "\ubc31\uadf8\ub77c\uc6b4\ub4dc \uc791\uc5c5\uc744 \uc81c\ud55c\ud574\ub3c4 \uad1c\ucc2e\uc740 \uc571\ub9cc \uace0\ub974\uc138\uc694. \uba54\uc2e0\uc800, \uc54c\ub78c, VPN, \uc6e8\uc5b4\ub7ec\ube14, \uc0bc\uc131 \uae30\ub2a5 \uc81c\uacf5 \uc571\uc744 \uc81c\ud55c\ud558\uba74 \uc815\uc0c1 \ub3d9\uc791\uc774 \uae68\uc9c8 \uc218 \uc788\uc2b5\ub2c8\ub2e4. Balanced\uc640 Efficiency\ub294 \uc571\uc744 \uc120\ud0dd\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Open the download folder in your browser"

    const-string v1, "\ube0c\ub77c\uc6b0\uc800\uc5d0\uc11c \ub2e4\uc6b4\ub85c\ub4dc \ud3f4\ub354 \uc5f4\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Operation failed: "

    const-string v1, "\uc791\uc5c5 \uc2e4\ud328: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Outside stock RPMh requests. "

    const-string v1, "\uc21c\uc815 RPMh \uc694\uccad \ubc94\uc704\ub97c \ubc97\uc5b4\ub0ac\uc2b5\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Outside stock frequency table. "

    const-string v1, "\uc21c\uc815 \uc8fc\ud30c\uc218 \ud14c\uc774\ube14\uc744 \ubc97\uc5b4\ub0ac\uc2b5\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "PACKAGE_INFO (1032) \u2014 package details"

    const-string v1, "PACKAGE_INFO (1032) \u2014 \ud328\ud0a4\uc9c0 \uc138\ubd80 \uc815\ubcf4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Package checksum failed: "

    const-string v1, "\ud328\ud0a4\uc9c0 \uccb4\ud06c\uc12c \uc2e4\ud328: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Pinned Samsung S918BXXUAZZI8 table defaults"

    const-string v1, "\uace0\uc815\ub41c \uc0bc\uc131 S918BXXUAZZI8 \ud14c\uc774\ube14 \uae30\ubcf8\uac12"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Power level "

    const-string v1, "\uc804\ub825 \ub2e8\uacc4 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Predefined action"

    const-string v1, "\uae30\ubcf8 \uc81c\uacf5 \ub3d9\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Preset: "

    const-string v1, "\ud504\ub9ac\uc14b: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Private DNS provider hostname"

    const-string v1, "\uac1c\uc778 DNS \uc81c\uacf5\uc790 \ud638\uc2a4\ud2b8 \uc774\ub984"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Profile backup"

    const-string v1, "\ud504\ub85c\ud544 \ubc31\uc5c5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Profile operation failed"

    const-string v1, "\ud504\ub85c\ud544 \uc791\uc5c5 \uc2e4\ud328"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Profile operation failed: "

    const-string v1, "\ud504\ub85c\ud544 \uc791\uc5c5 \uc2e4\ud328: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Quick Tiles"

    const-string v1, "\ube60\ub978 \uc124\uc815 \ud0c0\uc77c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "RAW EXPERIMENTAL"

    const-string v1, "RAW \uc2e4\ud5d8\uc801"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Rare"

    const-string v1, "\ub4dc\ubb3c\uac8c \uc0ac\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Rare (40)"

    const-string v1, "\ub4dc\ubb3c\uac8c \uc0ac\uc6a9 (40)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Raw RPMh request, 1\u2013480. This is not millivolts or a hardware-supported range. Request 1 and values outside stock are experimental."

    const-string v1, "RPMh \uc6d0\uc2dc \uc694\uccad \uac12, 1\u2013480. \ubc00\ub9ac\ubcfc\ud2b8\ub098 \ud558\ub4dc\uc6e8\uc5b4 \uc9c0\uc6d0 \ubc94\uc704\uac00 \uc544\ub2d9\ub2c8\ub2e4. \uc694\uccad \uac12 1\uacfc \uc21c\uc815 \ubc94\uc704\ub97c \ubc97\uc5b4\ub09c \uac12\uc740 \uc2e4\ud5d8\uc801\uc785\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Readback differs: requested "

    const-string v1, "\ub2e4\uc2dc \uc77d\uc740 \uac12\uc774 \ub2e4\ub984: \uc694\uccad "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reading OTA: "

    const-string v1, "OTA \uc77d\ub294 \uc911: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reboot"

    const-string v1, "\uc7ac\ubd80\ud305"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reboot device?"

    const-string v1, "\uae30\uae30\ub97c \uc7ac\ubd80\ud305\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Rebooting into OrangeFox\u2026"

    const-string v1, "OrangeFox\ub85c \uc7ac\ubd80\ud305\ud558\ub294 \uc911\u2026"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Recovery rollback"

    const-string v1, "\ub9ac\ucee4\ubc84\ub9ac \ub864\ubc31"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Red values are outside stock or change bus/ACD behavior. They may map to different corners, freeze the GPU or prevent booting. Request 1 is experimental and is not 1 mV."

    const-string v1, "\ube68\uac04 \uac12\uc740 \uc21c\uc815 \ubc94\uc704\ub97c \ubc97\uc5b4\ub0ac\uac70\ub098 \ubc84\uc2a4/ACD \ub3d9\uc791\uc744 \ubc14\uafc9\ub2c8\ub2e4. \ub2e4\ub978 \ucf54\ub108\ub85c \ub300\uc751\ub418\uac70\ub098 GPU\uac00 \uba48\ucd94\uac70\ub098 \ubd80\ud305\uc774 \uc548 \ub420 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc694\uccad \uac12 1\uc740 \uc2e4\ud5d8\uc801\uc774\uba70 1 mV\uac00 \uc544\ub2d9\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Refresh device status"

    const-string v1, "\uae30\uae30 \uc0c1\ud0dc \uc0c8\ub85c \uace0\uce68"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Refresh image and compatibility"

    const-string v1, "\uc774\ubbf8\uc9c0\uc640 \ud638\ud658\uc131 \uc0c8\ub85c \uace0\uce68"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Remove"

    const-string v1, "\uc0ad\uc81c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Remove only unnecessary user-added exemptions. Essential messaging and service dependencies should retain them. System exemptions may be protected by Android."

    const-string v1, "\uc0ac\uc6a9\uc790\uac00 \ucd94\uac00\ud55c \ubd88\ud544\uc694\ud55c \uc608\uc678\ub9cc \uc0ad\uc81c\ud558\uc138\uc694. \uaf2d \ud544\uc694\ud55c \uba54\uc2e0\uc800\uc640 \uc11c\ube44\uc2a4 \uc758\uc874 \uc571\uc740 \uc720\uc9c0\ud574\uc57c \ud569\ub2c8\ub2e4. \uc2dc\uc2a4\ud15c \uc608\uc678\ub294 Android\uac00 \ubcf4\ud638\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Remove power level "

    const-string v1, "\uc804\ub825 \ub2e8\uacc4 \uc0ad\uc81c "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Replace saved profile values?"

    const-string v1, "\uc800\uc7a5\ub41c \ud504\ub85c\ud544 \uac12\uc744 \ubc14\uafc0\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reply"

    const-string v1, "\ub2f5\uc7a5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reply to "

    const-string v1, "\ub2f5\uc7a5: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reset"

    const-string v1, "\ucd08\uae30\ud654"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Reset this slot"

    const-string v1, "\uc774 \uc2ac\ub86f \ucd08\uae30\ud654"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restart backup"

    const-string v1, "\ubc31\uc5c5 \ub2e4\uc2dc \uc2dc\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restart backup for this ROM?"

    const-string v1, "\uc774 \ub86c\uc758 \ubc31\uc5c5\uc744 \ub2e4\uc2dc \uc2dc\uc791\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restart into OrangeFox to install the verified update"

    const-string v1, "\uac80\uc99d\ub41c \uc5c5\ub370\uc774\ud2b8\ub97c \uc124\uce58\ud558\ub824\uba74 OrangeFox\ub85c \ub2e4\uc2dc \uc2dc\uc791\ud558\uc138\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restart protected apps so restored package visibility and process permission changes apply."

    const-string v1, "\ubcf5\uc6d0\ub41c \ud328\ud0a4\uc9c0 \ud45c\uc2dc \uc5ec\ubd80\uc640 \ud504\ub85c\uc138\uc2a4 \uad8c\ud55c \ubcc0\uacbd\uc744 \uc801\uc6a9\ud558\ub824\uba74 \ubcf4\ud638 \ub300\uc0c1 \uc571\uc744 \ub2e4\uc2dc \uc2dc\uc791\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore"

    const-string v1, "\ubcf5\uc6d0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore and restart"

    const-string v1, "\ubcf5\uc6d0 \ud6c4 \ub2e4\uc2dc \uc2dc\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore deferred for "

    const-string v1, "\ubcf5\uc6d0 \ubcf4\ub958: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore failed for "

    const-string v1, "\ubcf5\uc6d0 \uc2e4\ud328: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore original GPU image?"

    const-string v1, "\uc6d0\ub798 GPU \uc774\ubbf8\uc9c0\ub85c \ubcf5\uc6d0\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore profile"

    const-string v1, "\ud504\ub85c\ud544 \ubcf5\uc6d0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restore profile?"

    const-string v1, "\ud504\ub85c\ud544\uc744 \ubcf5\uc6d0\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restrict Zygote permissions"

    const-string v1, "Zygote \uad8c\ud55c \uc81c\ud55c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restricted"

    const-string v1, "\uc81c\ud55c\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Restricted (45)"

    const-string v1, "\uc81c\ud55c\ub428 (45)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Review its frequency, RPMh, bus and ACD values. These draft values are not a stability recommendation."

    const-string v1, "\uc8fc\ud30c\uc218, RPMh, \ubc84\uc2a4, ACD \uac12\uc744 \ud655\uc778\ud558\uc138\uc694. \uc774 \ucd08\uc548 \uac12\uc740 \uc548\uc815\uc131\uc744 \uad8c\uc7a5\ud558\ub294 \uac12\uc774 \uc544\ub2d9\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Ring"

    const-string v1, "\uc18c\ub9ac"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Rollback export failed"

    const-string v1, "\ub864\ubc31 \ub0b4\ubcf4\ub0b4\uae30 \uc2e4\ud328"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

.method private static fill2(Ljava/util/HashMap;)V
    .locals 2

    const-string v0, "Rollback export failed: "

    const-string v1, "\ub864\ubc31 \ub0b4\ubcf4\ub0b4\uae30 \uc2e4\ud328: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Rollback unavailable"

    const-string v1, "\ub864\ubc31\uc744 \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Root managers and rooted apps"

    const-string v1, "\ub8e8\ud2b8 \uad00\ub9ac\uc790 \ubc0f \ub8e8\ud305 \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "SDCARD_RW (1015) \u2014 media write access"

    const-string v1, "SDCARD_RW (1015) \u2014 \ubbf8\ub514\uc5b4 \uc4f0\uae30 \uad8c\ud55c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "SHARED_USER (9997) \u2014 may block all shared storage access"

    const-string v1, "SHARED_USER (9997) \u2014 \uacf5\uc720 \uc800\uc7a5\uc18c \uc811\uadfc\uc774 \ubaa8\ub450 \ub9c9\ud790 \uc218 \uc788\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Samsung Galaxy Store"

    const-string v1, "\uc0bc\uc131 Galaxy Store"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save"

    const-string v1, "\uc800\uc7a5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save and add to Quick Settings"

    const-string v1, "\uc800\uc7a5\ud558\uace0 \ube60\ub978 \uc124\uc815\uc5d0 \ucd94\uac00"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save and apply"

    const-string v1, "\uc800\uc7a5 \ubc0f \uc801\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save selection"

    const-string v1, "\uc120\ud0dd \uc800\uc7a5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save, apply & restart"

    const-string v1, "\uc800\uc7a5, \uc801\uc6a9 \ud6c4 \ub2e4\uc2dc \uc2dc\uc791"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Save, apply and restart?"

    const-string v1, "\uc800\uc7a5\ud558\uace0 \uc801\uc6a9\ud55c \ub4a4 \ub2e4\uc2dc \uc2dc\uc791\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Saved profile unavailable"

    const-string v1, "\uc800\uc7a5\ub41c \ud504\ub85c\ud544\uc744 \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Saved value "

    const-string v1, "\uc800\uc7a5\ub41c \uac12 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Saving verified OTA"

    const-string v1, "\uac80\uc99d\ub41c OTA \uc800\uc7a5 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Screen recording"

    const-string v1, "\ud654\uba74 \ub179\ud654"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Search app name or package"

    const-string v1, "\uc571 \uc774\ub984 \ub610\ub294 \ud328\ud0a4\uc9c0 \uac80\uc0c9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Search apps"

    const-string v1, "\uc571 \uac80\uc0c9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Select a local OTA ZIP"

    const-string v1, "\uae30\uae30\uc5d0 \uc788\ub294 OTA ZIP \uc120\ud0dd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Select an OTA ZIP to check for an update."

    const-string v1, "\uc5c5\ub370\uc774\ud2b8\ub97c \ud655\uc778\ud560 OTA ZIP\uc744 \uc120\ud0dd\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Select the downloaded OTA ZIP first."

    const-string v1, "\uba3c\uc800 \ub2e4\uc6b4\ub85c\ub4dc\ud55c OTA ZIP\uc744 \uc120\ud0dd\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Selected Exempted Apps will be disabled completely while Battery Saving is enabled. Apps removed from the selection, or all saved apps when Battery Saving is turned off, will return to their original enabled states. Calls, alarms, notifications and connectivity can stop working. Save your work. After successful app-state changes this phone will restart automatically. If changes fail, it will stay on so you can review the errors. Disabling takes effect immediately; the restart completes this workflow."

    const-string v1, "\ubc30\ud130\ub9ac \uc808\uc57d\uc774 \ucf1c\uc838 \uc788\ub294 \ub3d9\uc548 \uc120\ud0dd\ud55c \uc608\uc678 \uc571\uc740 \uc644\uc804\ud788 \uc0ac\uc6a9 \uc911\uc9c0\ub429\ub2c8\ub2e4. \uc120\ud0dd\uc5d0\uc11c \ube80 \uc571, \ub610\ub294 \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub04c \ub54c \uc800\uc7a5\ub41c \ubaa8\ub4e0 \uc571\uc740 \uc6d0\ub798 \uc0ac\uc6a9 \uc0c1\ud0dc\ub85c \ub3cc\uc544\uac11\ub2c8\ub2e4. \uc804\ud654, \uc54c\ub78c, \uc54c\ub9bc, \uc5f0\uacb0\uc774 \uc791\ub3d9\ud558\uc9c0 \uc54a\uc744 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \ud558\ub358 \uc791\uc5c5\uc744 \uc800\uc7a5\ud558\uc138\uc694. \uc571 \uc0c1\ud0dc \ubcc0\uacbd\uc774 \uc131\uacf5\ud558\uba74 \ud734\ub300\uc804\ud654\uac00 \uc790\ub3d9\uc73c\ub85c \ub2e4\uc2dc \uc2dc\uc791\ub429\ub2c8\ub2e4. \ubcc0\uacbd\uc5d0 \uc2e4\ud328\ud558\uba74 \uc624\ub958\ub97c \ud655\uc778\ud560 \uc218 \uc788\ub3c4\ub85d \ucf1c\uc9c4 \uc0c1\ud0dc\ub85c \ub461\ub2c8\ub2e4. \uc0ac\uc6a9 \uc911\uc9c0\ub294 \ubc14\ub85c \uc801\uc6a9\ub418\uba70, \ub2e4\uc2dc \uc2dc\uc791\ud558\uba74 \uc774 \uacfc\uc815\uc774 \ub9c8\ubb34\ub9ac\ub429\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Selected app restrictions can interrupt notifications, alarms, calls, account services and background work. Wi-Fi radio off disconnects all Wi-Fi; Wi-Fi Calling off can prevent calls where cellular coverage is poor. Only the selected controls and apps will change. Disable Battery Saving to restore saved settings."

    const-string v1, "\uc120\ud0dd\ud55c \uc571 \uc81c\ud55c\uc740 \uc54c\ub9bc, \uc54c\ub78c, \uc804\ud654, \uacc4\uc815 \uc11c\ube44\uc2a4, \ubc31\uadf8\ub77c\uc6b4\ub4dc \uc791\uc5c5\uc744 \ubc29\ud574\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4. Wi-Fi \ubb34\uc120\uc744 \ub044\uba74 \ubaa8\ub4e0 Wi-Fi \uc5f0\uacb0\uc774 \ub04a\uae30\uace0, Wi-Fi \ud1b5\ud654\ub97c \ub044\uba74 \uc140\ub8f0\ub7ec \uc218\uc2e0\uc774 \uc57d\ud55c \uacf3\uc5d0\uc11c \uc804\ud654\uac00 \uc548 \ub420 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc120\ud0dd\ud55c \ud56d\ubaa9\uacfc \uc571\ub9cc \ubc14\ub01d\ub2c8\ub2e4. \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub044\uba74 \uc800\uc7a5\ub41c \uc124\uc815\uc73c\ub85c \ub3cc\uc544\uac11\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Send"

    const-string v1, "\ubcf4\ub0b4\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Setting changed"

    const-string v1, "\uc124\uc815 \ubcc0\uacbd"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Sharing screen"

    const-string v1, "\ud654\uba74 \uacf5\uc720 \uc911"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Shizuku / Dhizuku apps"

    const-string v1, "Shizuku / Dhizuku \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Shortcut access is unavailable for this app."

    const-string v1, "\uc774 \uc571\uc758 \ubc14\ub85c\uac00\uae30\ub97c \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Silent"

    const-string v1, "\ubb34\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Sound mode"

    const-string v1, "\uc18c\ub9ac \ubaa8\ub4dc"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Spoof installation source"

    const-string v1, "\uc124\uce58 \ucd9c\ucc98 \uc704\uc7a5"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Standby bucket readback differs: requested "

    const-string v1, "\ub300\uae30 \ubc84\ud0b7 \uac12\uc774 \ub2e4\ub984: \uc694\uccad "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Stingy: aggressive saving"

    const-string v1, "Stingy: \uac15\ub825 \uc808\uc57d"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Stock comparison unavailable. "

    const-string v1, "\uc21c\uc815 \uac12\uacfc \ube44\uad50\ud560 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Stop"

    const-string v1, "\uc911\uc9c0"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Super fast charging"

    const-string v1, "\ucd08\uace0\uc18d \ucda9\uc804"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Suspicious apps"

    const-string v1, "\uc758\uc2ec \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "SystemUI restart was not permitted"

    const-string v1, "SystemUI \ub2e4\uc2dc \uc2dc\uc791\uc774 \ud5c8\uc6a9\ub418\uc9c0 \uc54a\uc558\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Table 0 \u00b7 SKU-specific"

    const-string v1, "\ud14c\uc774\ube14 0 \u00b7 SKU \uc804\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Table 1 \u00b7 fallback"

    const-string v1, "\ud14c\uc774\ube14 1 \u00b7 \ub300\uccb4\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Targeted app restrictions"

    const-string v1, "\ub300\uc0c1 \uc571 \uc81c\ud55c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The current HMA configuration was exported as an HMA-OSS style JSON file."

    const-string v1, "\ud604\uc7ac HMA \uc124\uc815\uc744 HMA-OSS \ud615\uc2dd\uc758 JSON \ud30c\uc77c\ub85c \ub0b4\ubcf4\ub0c8\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The current image differs from the saved original. Copy and verify the old rollback in protected /data storage before freeing its /cache space. Then back up this ROM\'s clean vendor_boot and save the new rollback ZIP to PC or USB. Your tuning profile stays saved. This does not flash either image."

    const-string v1, "\ud604\uc7ac \uc774\ubbf8\uc9c0\uac00 \uc800\uc7a5\ub41c \uc6d0\ubcf8\uacfc \ub2e4\ub985\ub2c8\ub2e4. /cache \uacf5\uac04\uc744 \ube44\uc6b0\uae30 \uc804\uc5d0 \uc774\uc804 \ub864\ubc31\uc744 \ubcf4\ud638\ub41c /data \uc800\uc7a5\uc18c\uc5d0 \ubcf5\uc0ac\ud574 \uac80\uc99d\ud558\uc138\uc694. \uadf8\ub2e4\uc74c \uc774 \ub86c\uc758 \uae68\ub057\ud55c vendor_boot\ub97c \ubc31\uc5c5\ud558\uace0 \uc0c8 \ub864\ubc31 ZIP\uc744 PC\ub098 USB\uc5d0 \uc800\uc7a5\ud558\uc138\uc694. \ud29c\ub2dd \ud504\ub85c\ud544\uc740 \uadf8\ub300\ub85c \uc800\uc7a5\ub3fc \uc788\uc2b5\ub2c8\ub2e4. \uc5b4\ub290 \uc774\ubbf8\uc9c0\ub3c4 \ud50c\ub798\uc2dc\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The phone will restart into OrangeFox. Press Volume Down during its initial 5-second countdown to cancel."

    const-string v1, "\ud734\ub300\uc804\ud654\uac00 OrangeFox\ub85c \ub2e4\uc2dc \uc2dc\uc791\ub429\ub2c8\ub2e4. \ucde8\uc18c\ud558\ub824\uba74 \ucc98\uc74c 5\ucd08 \uce74\uc6b4\ud2b8\ub2e4\uc6b4 \uc911\uc5d0 \ubcfc\ub968 \ud558 \ubc84\ud2bc\uc744 \ub204\ub974\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The previous backup refresh belongs to a different image. Preserve and verify its rollback, journal and staged files in protected /data storage before freeing their cache space. Then create this ROM\'s clean backup. Save the NEW rollback ZIP to PC or USB before Apply. Your tuning profile stays saved. This does not flash any image."

    const-string v1, "\uc774\uc804 \ubc31\uc5c5 \uac31\uc2e0\uc740 \ub2e4\ub978 \uc774\ubbf8\uc9c0\uc758 \uac83\uc785\ub2c8\ub2e4. \uce90\uc2dc \uacf5\uac04\uc744 \ube44\uc6b0\uae30 \uc804\uc5d0 \uadf8 \ub864\ubc31, \uc800\ub110, \uc900\ube44 \ud30c\uc77c\uc744 \ubcf4\ud638\ub41c /data \uc800\uc7a5\uc18c\uc5d0 \ubcf4\uc874\ud558\uace0 \uac80\uc99d\ud558\uc138\uc694. \uadf8\ub2e4\uc74c \uc774 \ub86c\uc758 \uae68\ub057\ud55c \ubc31\uc5c5\uc744 \ub9cc\ub4dc\uc138\uc694. \uc801\uc6a9\ud558\uae30 \uc804\uc5d0 \uc0c8 \ub864\ubc31 ZIP\uc744 PC\ub098 USB\uc5d0 \uc800\uc7a5\ud558\uc138\uc694. \ud29c\ub2dd \ud504\ub85c\ud544\uc740 \uadf8\ub300\ub85c \uc800\uc7a5\ub3fc \uc788\uc2b5\ub2c8\ub2e4. \uc5b4\ub5a4 \uc774\ubbf8\uc9c0\ub3c4 \ud50c\ub798\uc2dc\ud558\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The saved data was kept for recovery. "

    const-string v1, "\ubcf5\uad6c\ub97c \uc704\ud574 \uc800\uc7a5\ub41c \ub370\uc774\ud130\ub97c \uc720\uc9c0\ud588\uc2b5\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "The settings provider rejected this change."

    const-string v1, "\uc124\uc815 \uc81c\uacf5\uc790\uac00 \uc774 \ubcc0\uacbd\uc744 \uac70\ubd80\ud588\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This app or its shared UID is protected for recovery"

    const-string v1, "\uc774 \uc571 \ub610\ub294 \uacf5\uc720 UID\ub294 \ubcf5\uad6c\uc6a9\uc73c\ub85c \ubcf4\ud638\ub429\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This changes the saved table structure. Remaining levels are renumbered and initial/minimum references adjusted. Keep at least two levels. Apply is a separate action."

    const-string v1, "\uc800\uc7a5\ub41c \ud14c\uc774\ube14 \uad6c\uc870\uac00 \ubc14\ub01d\ub2c8\ub2e4. \ub0a8\uc740 \ub2e8\uacc4\uc758 \ubc88\ud638\uac00 \ub2e4\uc2dc \ub9e4\uaca8\uc9c0\uace0 \ucd08\uae30/\ucd5c\uc18c \ucc38\uc870\uac00 \uc870\uc815\ub429\ub2c8\ub2e4. \ucd5c\uc18c \ub450 \ub2e8\uacc4\ub294 \ub0a8\uaca8\uc57c \ud569\ub2c8\ub2e4. \uc801\uc6a9\uc740 \ub530\ub85c \ud574\uc57c \ud569\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This driver clamps active-row DDR requests above 9 to 9. "

    const-string v1, "\uc774 \ub4dc\ub77c\uc774\ubc84\ub294 \ud65c\uc131 \ud589\uc758 DDR \uc694\uccad\uc774 9\ub97c \ub118\uc73c\uba74 9\ub85c \uc81c\ud55c\ud569\ub2c8\ub2e4. "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This profile deliberately sacrifices performance and background functions. Notifications, background sync, uploads, backups, app-store updates, widgets, VPNs and wearables can stop working. The screen becomes dim with a short timeout; CPU/GPU speed is heavily capped. Aggressive PCIe saving may expose driver instability. Play services, Play Store, Galaxy Store and non-essential system apps are restricted. Alarms, calls and connectivity can also fail. Core UIDs, Settings, SystemUI, credential and permission components, launcher, enabled keyboards, accessibility services and device administrators remain protected for recovery. Android exemptions and foreground services mean zero background activity is not guaranteed. Disable Battery Saving to restore saved settings; missed work and notifications cannot be recovered. Select the preset, then Save and apply."

    const-string v1, "\uc774 \ud504\ub85c\ud544\uc740 \uc131\ub2a5\uacfc \ubc31\uadf8\ub77c\uc6b4\ub4dc \uae30\ub2a5\uc744 \uc77c\ubd80\ub7ec \ud76c\uc0dd\ud569\ub2c8\ub2e4. \uc54c\ub9bc, \ubc31\uadf8\ub77c\uc6b4\ub4dc \ub3d9\uae30\ud654, \uc5c5\ub85c\ub4dc, \ubc31\uc5c5, \uc571 \uc2a4\ud1a0\uc5b4 \uc5c5\ub370\uc774\ud2b8, \uc704\uc82f, VPN, \uc6e8\uc5b4\ub7ec\ube14\uc774 \uc791\ub3d9\ud558\uc9c0 \uc54a\uc744 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \ud654\uba74\uc774 \uc5b4\ub450\uc6cc\uc9c0\uace0 \ud654\uba74 \uaebc\uc9d0 \uc2dc\uac04\uc774 \uc9e7\uc544\uc9c0\uba70, CPU/GPU \uc18d\ub3c4\uac00 \ud06c\uac8c \uc81c\ud55c\ub429\ub2c8\ub2e4. \uac15\ud55c PCIe \uc808\uc804\uc73c\ub85c \ub4dc\ub77c\uc774\ubc84\uac00 \ubd88\uc548\uc815\ud574\uc9c8 \uc218 \uc788\uc2b5\ub2c8\ub2e4. Play \uc11c\ube44\uc2a4, Play \uc2a4\ud1a0\uc5b4, Galaxy Store\uc640 \ud544\uc218\uac00 \uc544\ub2cc \uc2dc\uc2a4\ud15c \uc571\uc774 \uc81c\ud55c\ub429\ub2c8\ub2e4. \uc54c\ub78c, \uc804\ud654, \uc5f0\uacb0\ub3c4 \uc2e4\ud328\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \ud575\uc2ec UID, \uc124\uc815, SystemUI, \uc778\uc99d\u00b7\uad8c\ud55c \uad6c\uc131\uc694\uc18c, \ub7f0\ucc98, \uc0ac\uc6a9 \uc911\uc778 \ud0a4\ubcf4\ub4dc, \uc811\uadfc\uc131 \uc11c\ube44\uc2a4, \uae30\uae30 \uad00\ub9ac\uc790\ub294 \ubcf5\uad6c\ub97c \uc704\ud574 \ubcf4\ud638\ub429\ub2c8\ub2e4. Android \uc608\uc678\uc640 \ud3ec\uadf8\ub77c\uc6b4\ub4dc \uc11c\ube44\uc2a4 \ub54c\ubb38\uc5d0 \ubc31\uadf8\ub77c\uc6b4\ub4dc \ud65c\ub3d9\uc774 \uc644\uc804\ud788 \uc5c6\uc5b4\uc9c0\uc9c0\ub294 \uc54a\uc2b5\ub2c8\ub2e4. \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub044\uba74 \uc800\uc7a5\ub41c \uc124\uc815\uc73c\ub85c \ub3cc\uc544\uac00\uc9c0\ub9cc, \ub193\uce5c \uc791\uc5c5\uacfc \uc54c\ub9bc\uc740 \ubcf5\uad6c\ub418\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4. \ud504\ub9ac\uc14b\uc744 \uace0\ub978 \ub4a4 \uc800\uc7a5 \ubc0f \uc801\uc6a9\uc744 \ub204\ub974\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This replaces the saved draft. Back up your profile first if you want to keep it."

    const-string v1, "\uc800\uc7a5\ub41c \ucd08\uc548\uc744 \ub300\uccb4\ud569\ub2c8\ub2e4. \uc720\uc9c0\ud558\ub824\uba74 \uba3c\uc800 \ud504\ub85c\ud544\uc744 \ubc31\uc5c5\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This replaces your selected controls and turns Battery Saving off, restoring any current changes. Review the imported values before enabling it."

    const-string v1, "\uc120\ud0dd\ud55c \ud56d\ubaa9\uc744 \ub300\uccb4\ud558\uace0 \ubc30\ud130\ub9ac \uc808\uc57d\uc744 \ub044\uba74\uc11c \ud604\uc7ac \ubcc0\uacbd \uc0ac\ud56d\uc744 \ub418\ub3cc\ub9bd\ub2c8\ub2e4. \ucf1c\uae30 \uc804\uc5d0 \uac00\uc838\uc628 \uac12\uc744 \ud655\uc778\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This restores the full vendor_boot image captured before this trial, including its original GPU table. Reboot after restoration succeeds."

    const-string v1, "\uc774\ubc88 \uc2dc\ud5d8 \uc801\uc6a9 \uc804\uc5d0 \uc800\uc7a5\ud55c vendor_boot \uc774\ubbf8\uc9c0 \uc804\uccb4\ub97c \uc6d0\ub798 GPU \ud14c\uc774\ube14\uacfc \ud568\uaed8 \ubcf5\uc6d0\ud569\ub2c8\ub2e4. \ubcf5\uc6d0\uc774 \uc131\uacf5\ud558\uba74 \uc7ac\ubd80\ud305\ud558\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "This shortcut is no longer available. Choose it again in Quick Tiles."

    const-string v1, "\uc774 \ubc14\ub85c\uac00\uae30\ub294 \ub354 \uc774\uc0c1 \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4. \ube60\ub978 \uc124\uc815 \ud0c0\uc77c\uc5d0\uc11c \ub2e4\uc2dc \uace0\ub974\uc138\uc694."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Tile icon"

    const-string v1, "\ud0c0\uc77c \uc544\uc774\ucf58"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Tile is in Quick Settings"

    const-string v1, "\ud0c0\uc77c\uc774 \ube60\ub978 \uc124\uc815\uc5d0 \uc788\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Tile label"

    const-string v1, "\ud0c0\uc77c \uc774\ub984"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Tile saved"

    const-string v1, "\ud0c0\uc77c \uc800\uc7a5\ub428"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Transition animations"

    const-string v1, "\uc804\ud658 \uc560\ub2c8\uba54\uc774\uc158"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Trial changes"

    const-string v1, "\uc2dc\ud5d8 \uc801\uc6a9 \ubcc0\uacbd \uc0ac\ud56d"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Tuning profile"

    const-string v1, "\ud29c\ub2dd \ud504\ub85c\ud544"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Turn off"

    const-string v1, "\ub044\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Turning this off restores the values saved before this feature changed them. Changes below take effect after Save and apply."

    const-string v1, "\ub044\uba74 \uc774 \uae30\ub2a5\uc774 \uac12\uc744 \ubc14\uafb8\uae30 \uc804\uc5d0 \uc800\uc7a5\ud574 \ub454 \uac12\uc73c\ub85c \ub3cc\uc544\uac11\ub2c8\ub2e4. \uc544\ub798 \ubcc0\uacbd \uc0ac\ud56d\uc740 \uc800\uc7a5 \ubc0f \uc801\uc6a9 \ud6c4 \ubc18\uc601\ub429\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "UN1CA Tile "

    const-string v1, "UN1CA \ud0c0\uc77c "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unable to load installed apps"

    const-string v1, "\uc124\uce58\ub41c \uc571\uc744 \ubd88\ub7ec\uc62c \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unable to save tile"

    const-string v1, "\ud0c0\uc77c\uc744 \uc800\uc7a5\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unavailable on this device"

    const-string v1, "\uc774 \uae30\uae30\uc5d0\uc11c\ub294 \uc0ac\uc6a9\ud560 \uc218 \uc5c6\uc74c"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unknown ("

    const-string v1, "\uc54c \uc218 \uc5c6\uc74c ("

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unknown Installed"

    const-string v1, "\ucd9c\ucc98 \ubd88\uba85 \uc124\uce58 \uc571"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unknown control: "

    const-string v1, "\uc54c \uc218 \uc5c6\ub294 \ud56d\ubaa9: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unknown; imported upstream KonaBess export"

    const-string v1, "\uc54c \uc218 \uc5c6\uc74c; \uac00\uc838\uc628 \uc6d0\ubcf8 KonaBess \ub0b4\ubcf4\ub0b4\uae30"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Unsupported GPU property: "

    const-string v1, "\uc9c0\uc6d0\ub418\uc9c0 \uc54a\ub294 GPU \uc18d\uc131: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Up to six decimal places (1 Hz). Positive u32 Hz input only; this is a storage limit, not a supported clock range. Non-stock frequencies appear in red and can prevent booting."

    const-string v1, "\uc18c\uc218\uc810 \uc5ec\uc12f\uc9f8 \uc790\ub9ac(1 Hz)\uae4c\uc9c0 \uc785\ub825\ud560 \uc218 \uc788\uc2b5\ub2c8\ub2e4. \uc591\uc758 u32 Hz \uac12\ub9cc \ub429\ub2c8\ub2e4. \uc774\ub294 \uc800\uc7a5 \ud55c\ub3c4\uc77c \ubfd0 \uc9c0\uc6d0\ub418\ub294 \ud074\ub7ed \ubc94\uc704\uac00 \uc544\ub2d9\ub2c8\ub2e4. \uc21c\uc815\uc774 \uc544\ub2cc \uc8fc\ud30c\uc218\ub294 \ube68\uac04\uc0c9\uc73c\ub85c \ud45c\uc2dc\ub418\uba70 \ubd80\ud305\uc774 \uc548 \ub420 \uc218 \uc788\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Update status"

    const-string v1, "\uc5c5\ub370\uc774\ud2b8 \uc0c1\ud0dc"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Updater setup: "

    const-string v1, "\uc5c5\ub370\uc774\ud130 \uc124\uc815: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Use experimental RPMh request?"

    const-string v1, "\uc2e4\ud5d8\uc801 RPMh \uc694\uccad \uac12\uc744 \uc0ac\uc6a9\ud560\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Use request"

    const-string v1, "\uc694\uccad \uac12 \uc0ac\uc6a9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Values are saved automatically and retained across ROM updates that preserve Settings data. Imported values are never applied automatically."

    const-string v1, "\uac12\uc740 \uc790\ub3d9\uc73c\ub85c \uc800\uc7a5\ub418\uba70 \uc124\uc815 \ub370\uc774\ud130\ub97c \uc720\uc9c0\ud558\ub294 \ub86c \uc5c5\ub370\uc774\ud2b8 \ud6c4\uc5d0\ub3c4 \ub0a8\uc544 \uc788\uc2b5\ub2c8\ub2e4. \uac00\uc838\uc628 \uac12\uc740 \uc790\ub3d9\uc73c\ub85c \uc801\uc6a9\ub418\uc9c0 \uc54a\uc2b5\ub2c8\ub2e4."

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Verification code"

    const-string v1, "\uc778\uc99d \ucf54\ub4dc"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Verifying OTA before reboot\u2026"

    const-string v1, "\uc7ac\ubd80\ud305 \uc804\uc5d0 OTA \uac80\uc99d \uc911\u2026"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Verifying selected OTA\u2026"

    const-string v1, "\uc120\ud0dd\ud55c OTA \uac80\uc99d \uc911\u2026"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Vibrate"

    const-string v1, "\uc9c4\ub3d9"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Voltage request \u00b7 table "

    const-string v1, "\uc804\uc555 \uc694\uccad \u00b7 \ud14c\uc774\ube14 "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wait for the GPU operation to finish"

    const-string v1, "GPU \uc791\uc5c5\uc774 \ub05d\ub0a0 \ub54c\uae4c\uc9c0 \uae30\ub2e4\ub9ac\uc138\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wait for the battery operation to finish"

    const-string v1, "\ubc30\ud130\ub9ac \uc791\uc5c5\uc774 \ub05d\ub0a0 \ub54c\uae4c\uc9c0 \uae30\ub2e4\ub9ac\uc138\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wait for the update operation to finish"

    const-string v1, "\uc5c5\ub370\uc774\ud2b8 \uc791\uc5c5\uc774 \ub05d\ub0a0 \ub54c\uae4c\uc9c0 \uae30\ub2e4\ub9ac\uc138\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wi-Fi Calling discovery unavailable: "

    const-string v1, "Wi-Fi \ud1b5\ud654 \uc815\ubcf4\ub97c \ud655\uc778\ud560 \uc218 \uc5c6\uc74c: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wi-Fi Calling \u00b7 SIM "

    const-string v1, "Wi-Fi \ud1b5\ud654 \u00b7 SIM "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Window animations"

    const-string v1, "\ucc3d \uc560\ub2c8\uba54\uc774\uc158"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Wireless debugging settings"

    const-string v1, "\ubb34\uc120 \ub514\ubc84\uae45 \uc124\uc815"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Working set"

    const-string v1, "\uc791\uc5c5 \uc138\ud2b8"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Working set (20)"

    const-string v1, "\uc791\uc5c5 \uc138\ud2b8 (20)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Working: "

    const-string v1, "\uc9c4\ud589 \uc911: "

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Write both GPU tables to vendor_boot?"

    const-string v1, "GPU \ud14c\uc774\ube14 \ub450 \uac1c\ub97c vendor_boot\uc5d0 \uc4f8\uae4c\uc694?"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "its app is open"

    const-string v1, "\ud574\ub2f9 \uc571\uc774 \uc5f4\ub824 \uc788\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "not shown: island hidden (lock screen, full screen or landscape)"

    const-string v1, "\ud45c\uc2dc \uc548 \ub428: \uc544\uc77c\ub79c\ub4dc \uc228\uae40 (\uc7a0\uae08 \ud654\uba74, \uc804\uccb4 \ud654\uba74 \ub610\ub294 \uac00\ub85c \ubaa8\ub4dc)"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "not shown: the island could not open"

    const-string v1, "\ud45c\uc2dc \uc548 \ub428: \uc544\uc77c\ub79c\ub4dc\ub97c \uc5f4 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "not shown: the messages app is open"

    const-string v1, "\ud45c\uc2dc \uc548 \ub428: \uba54\uc2dc\uc9c0 \uc571\uc774 \uc5f4\ub824 \uc788\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "required before Apply"

    const-string v1, "\uc801\uc6a9 \uc804\uc5d0 \ud544\uc694"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "the notification settings are off"

    const-string v1, "\uc54c\ub9bc \uc124\uc815\uc774 \uaebc\uc838 \uc788\uc2b5\ub2c8\ub2e4"

    invoke-virtual {p0, v0, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

