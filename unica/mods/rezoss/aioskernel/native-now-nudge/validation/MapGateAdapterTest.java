package io.mesalabs.rezoss.ai;

import android.app.ActivityThread;
import android.os.Looper;
import android.provider.Settings;
import java.util.*;
import org.json.JSONArray;

/** Exercises production Android adapter with settings, thread, JSON and reflective actions. */
public final class MapGateAdapterTest {
    private static int assertions;
    private static void check(boolean value) { assertions++; if (!value) throw new AssertionError(assertions); }
    public static final class Action {
        private final String type;
        private final Map<String,String> parameters;
        Action(String type, String key, String value) { this.type=type; parameters=Collections.singletonMap(key,value); }
        public String getActionType() { return type; }
        public Map<String,String> getParameters() { return parameters; }
    }
    public static final class ThrowingAction {
        public String getActionType() { throw new IllegalStateException(); }
        public Map<String,String> getParameters() { return Collections.emptyMap(); }
    }
    public static void main(String[] args) {
        List<String> neutral=Collections.singletonList("other");
        List<String> marked=NativeMapGate.extend("Directions to 10 Downing Street, London",neutral);
        check(marked!=neutral && MapGateContract.fallback(marked));
        String json=new JSONArray(marked).toString();
        Object map=new Action("Browse Location","location","10 Downing Street, London");
        List<Object> actions=Arrays.asList(new Action("Call","number","123456789"),map,new Action("Mail","mail","a@b.com"),new Action("Set Reminder","title","Milk"));
        List<?> maps=NativeMapGate.filter(json,actions);
        check(maps.size()==1 && maps.get(0)==map);
        for(String label:Arrays.asList("is_unsafe","has_intention_action","has_intention_query","has_map_url")) {
            List<String> stock=Collections.singletonList(label);
            check(NativeMapGate.extend("Directions to London",stock)==stock);
            check(NativeMapGate.filter(new JSONArray(stock).toString(),actions)==actions);
        }
        check(NativeMapGate.filter("[]",actions)==actions);
        check(NativeMapGate.filter("[\"other\"]",actions)==actions);
        check(NativeMapGate.filter("[\"rezoss_map_fallback\"]",actions).isEmpty());
        check(NativeMapGate.filter("[\"other\",\"has_intention_action\",\"rezoss_map_fallback\",\"is_unsafe\"]",actions).isEmpty());
        check(NativeMapGate.filter("broken",actions).isEmpty());
        check(NativeMapGate.filter(json,null).isEmpty());
        check(NativeMapGate.filter(json,Collections.singletonList(new Object())).isEmpty());
        check(NativeMapGate.filter(json,Collections.singletonList(new ThrowingAction())).isEmpty());
        check(NativeMapGate.filter(json,Collections.singletonList(new Action("Browse Location","location","\nLondon"))).isEmpty());
        check(NativeMapGate.filter(json,Collections.singletonList(new Action("Browse Location","address","London"))).isEmpty());
        check(NativeMapGate.filter(json,Collections.singletonList(new Action("Browse Location","location",""))).isEmpty());
        for(String flag:Arrays.asList("rezoss_now_nudge_native","rezoss_now_nudge_context_actions","rezoss_aios_v73_backend")) {
            Settings.Global.disabled=flag;
            check(NativeMapGate.extend("Directions to London",neutral)==neutral);
            check(NativeMapGate.filter(json,actions).isEmpty());
            check(NativeMapGate.filter("[\"has_intention_action\"]",actions)==actions);
        }
        Settings.Global.disabled=null;
        Looper.main=true;
        check(NativeMapGate.extend("Directions to London",neutral)==neutral);
        Looper.main=false;
        ActivityThread.available=false;
        check(NativeMapGate.extend("Directions to London",neutral)==neutral);
        check(NativeMapGate.filter(json,actions).isEmpty());
        System.out.println("Map adapter assertions="+assertions);
    }
}
