package io.mesalabs.rezoss.qwen;

import android.os.Build;

/** SoC capabilities that decide which offline engines can run. */
final class Hardware {
    private Hardware() {}

    static String soc() {
        String model = Build.SOC_MODEL;
        return model == null ? "" : model.toUpperCase(java.util.Locale.ROOT);
    }

    /** SM8550 (Hexagon V73): the AIOS QNN Qwen3 runner is available. */
    static boolean v73() { return soc().startsWith("SM8550"); }

    /** Gemma's LiteRT GPU path is validated on Adreno 7xx (SM8550); other SoCs start on Qwen. */
    static boolean gemmaDefault() { return v73(); }
}
