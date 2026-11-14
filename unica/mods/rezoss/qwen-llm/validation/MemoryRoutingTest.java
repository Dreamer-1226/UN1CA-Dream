package io.mesalabs.rezoss.qwen;

import android.content.Context;
import android.content.SharedPreferences;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

/** Execute the production preference/router code without Android encryption. */
public final class MemoryRoutingTest {
    private static int checks;
    private static void check(boolean value){checks++;if(!value)throw new AssertionError("Memory route check "+checks);}
    private interface Operation {void run()throws Exception;}
    private static void denied(Operation action)throws Exception {try{action.run();throw new AssertionError("Route crossed task selection");}catch(IllegalArgumentException expected){checks++;}}
    public static void main(String[] args)throws Exception {
        Map<String,String> values=new HashMap<>();
        SharedPreferences.Editor editor=(SharedPreferences.Editor)Proxy.newProxyInstance(MemoryRoutingTest.class.getClassLoader(),new Class<?>[]{SharedPreferences.Editor.class},(p,m,a)->{if("putString".equals(m.getName()))values.put((String)a[0],(String)a[1]);return "apply".equals(m.getName())?null:p;});
        SharedPreferences preferences=(SharedPreferences)Proxy.newProxyInstance(MemoryRoutingTest.class.getClassLoader(),new Class<?>[]{SharedPreferences.class},(p,m,a)->"getString".equals(m.getName())?values.getOrDefault((String)a[0],(String)a[1]):"edit".equals(m.getName())?editor:null);
        Context context=new Context(){public SharedPreferences getSharedPreferences(String name,int mode){return preferences;}};
        check("default".equals(ApiSettingsStore.memoryBackend(context)));
        values.put("backend","openai");values.put("screening_backend","gemini");values.put("memory_backend","custom");values.put("endpoint","https://example.org/v1/chat/completions");values.put("model","test");
        check("test".equals(ApiSettingsStore.forMemoryBackend(context,"custom").model));
        denied(()->ApiSettingsStore.forBackend(context,"custom"));
        denied(()->ApiSettingsStore.forMemoryBackend(context,"openai"));
        denied(()->ApiSettingsStore.forMemoryBackend(context,"gemini"));
        ApiSettingsStore.selectMemory(context,"default");
        check("default".equals(ApiSettingsStore.memoryBackend(context)));
        check("openai".equals(ApiSettingsStore.backend(context,false)));check("gemini".equals(ApiSettingsStore.backend(context,true)));
        denied(()->ApiSettingsStore.forMemoryBackend(context,"custom"));
        values.put("memory_backend","custom");ApiSettingsStore.select(context,"default",true);
        check("custom".equals(ApiSettingsStore.memoryBackend(context)));check("openai".equals(ApiSettingsStore.backend(context,false)));
        denied(()->ApiSettingsStore.selectMemory(context,"unknown"));
        System.out.println("Memory routes: "+checks+" checks passed");
    }
}
