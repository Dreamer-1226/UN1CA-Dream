package io.mesalabs.rezoss.ai;

import android.content.Context;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;

/** Neutral-gate fallback into Samsung's existing recall model, limited to Maps. */
public final class NativeMapGate {
    private NativeMapGate() {}
    private static boolean enabled() {
        try {
            Context context = (Context) Class.forName("android.app.ActivityThread")
                    .getMethod("currentApplication").invoke(null);
            return context != null
                    && Settings.Global.getInt(context.getContentResolver(), "rezoss_now_nudge_native", 0) == 1
                    && Settings.Global.getInt(context.getContentResolver(), "rezoss_now_nudge_context_actions", 0) == 1
                    && aiosBackend(context);
        } catch (Exception | LinkageError unavailable) { return false; }
    }
    /** The boot script seeds this setting from ro.unica.now_nudge_v73, but it runs from init, whose
     *  binder calls to the settings service can fail; then the setting stays absent and every request
     *  fell back to the API-only engine. Read the build property when the setting was never written;
     *  an explicit 0 still opts out. */
    private static boolean aiosBackend(Context context) {
        String value = Settings.Global.getString(context.getContentResolver(), "rezoss_aios_v73_backend");
        if (value != null) return "1".equals(value.trim());
        try {
            Object prop = Class.forName("android.os.SystemProperties").getMethod("get", String.class, String.class)
                    .invoke(null, "ro.unica.now_nudge_v73", "0");
            return "1".equals(prop);
        } catch (Exception | LinkageError unavailable) { return false; }
    }
    public static List<String> beforeFilter(List<?> labels) {
        List<String> result = MapGateContract.beforeFilter(labels, enabled(),
                Looper.myLooper() != Looper.getMainLooper());
        if (result != null) Log.i("RezossMapGate", "neutral prediction retained before Samsung filtering");
        return result;
    }
    public static List<String> extend(String input, List<String> labels) {
        List<String> result = MapGateContract.extend(input, labels, enabled(),
                Looper.myLooper() != Looper.getMainLooper());
        if (result != labels) Log.i("RezossMapGate", "neutral candidate forwarded to Samsung recall");
        return result;
    }
    public static List<?> filter(String gatingJson, List<?> actions) {
        try {
            JSONArray json = new JSONArray(gatingJson);
            List<String> labels = new ArrayList<>();
            for (int i = 0; i < json.length(); i++) labels.add(json.getString(i));
            if (!MapGateContract.marked(labels)) return actions;
            if (!enabled() || !MapGateContract.fallback(labels) || actions == null) return Collections.emptyList();
            List<Object> maps = new ArrayList<>();
            for (Object action : actions) {
                if (action == null) continue;
                String type = (String) action.getClass().getMethod("getActionType").invoke(action);
                Map<?, ?> parameters = (Map<?, ?>) action.getClass().getMethod("getParameters").invoke(action);
                if (MapGateContract.mapAction(type, parameters)) maps.add(action);
            }
            Log.i("RezossMapGate", "validated map actions=" + maps.size());
            return maps;
        } catch (Exception | LinkageError unavailable) {
            Log.i("RezossMapGate", "fallback rejected");
            return Collections.emptyList();
        }
    }
}
