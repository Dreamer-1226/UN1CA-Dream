package io.mesalabs.rezoss.ai;

import android.os.Looper;
import android.provider.Settings;
import java.nio.file.*;
import java.util.*;

/** Executes the actual patched runInference tail; unknown instructions fail closed. */
public final class MapGatePipelineTest {
    enum Label {
        OTHER("other"), HAS_INTENTION_ACTION("has_intention_action"),
        HAS_INTENTION_QUERY("has_intention_query"), IS_UNSAFE("is_unsafe"), HAS_MAP_URL("has_map_url");
        private final String text;
        Label(String text) { this.text=text; }
        public String toString() { return text; }
    }
    private static final Object FAILURE=new Object();
    private static int assertions;
    private static void check(boolean value) { assertions++; if (!value) throw new AssertionError("assertion="+assertions); }
    private static int reg(String value) { return Integer.parseInt(value.trim().substring(1)); }
    private static boolean zero(Object value) { return value==null || Boolean.FALSE.equals(value) || Integer.valueOf(0).equals(value); }
    private static List<?> execute(List<String> code,Object input,boolean early) {
        Object[] r=new Object[40]; r[0]=input;
        Map<String,Integer> labels=new HashMap<>();
        for(int i=0;i<code.size();i++) if(code.get(i).startsWith(":")) labels.put(code.get(i),i);
        Object result=null;
        for(int pc=0,steps=0;pc<code.size();pc++) {
            if(++steps>1000) throw new AssertionError("loop");
            String line=code.get(pc);
            if(line.startsWith(":") || line.startsWith(".")) continue;
            String op=line.split(" ",2)[0];
            String[] a=line.substring(op.length()).trim().split(",\\s*");
            if(op.equals("check-cast")) continue;
            if(op.startsWith("move-result")) { r[reg(a[0])]=result; continue; }
            if(op.startsWith("move-object")) { r[reg(a[0])]=r[reg(a[1])]; continue; }
            if(op.equals("const/16")) { r[reg(a[0])]=Integer.decode(a[1]); continue; }
            if(op.equals("instance-of")) { r[reg(a[0])]=r[reg(a[1])] instanceof Collection<?>; continue; }
            if(op.equals("new-instance")) { r[reg(a[0])]=new ArrayList<Object>(); continue; }
            if(op.equals("sget-object")) { String name=line.substring(line.indexOf("->")+2); name=name.substring(0,name.indexOf(':')); r[reg(a[0])]=Label.valueOf(name); continue; }
            if(op.equals("goto") || op.equals("goto/16")) { pc=labels.get(a[0]); continue; }
            if(op.equals("if-eqz") || op.equals("if-nez")) { if(zero(r[reg(a[0])])==op.equals("if-eqz")) pc=labels.get(a[1]); continue; }
            if(op.equals("return-object")) return (List<?>)r[reg(a[0])];
            if(op.equals("filled-new-array")) { String[] args=line.substring(line.indexOf('{')+1,line.indexOf('}')).split(",\\s*"); Object[] array=new Object[args.length]; for(int i=0;i<args.length;i++) array[i]=r[reg(args[i])]; result=array; continue; }
            if(op.startsWith("invoke-")) {
                String inside=line.substring(line.indexOf('{')+1,line.indexOf('}'));
                String[] args=inside.isEmpty()?new String[0]:inside.split(",\\s*");
                Object receiver=args.length==0?null:r[reg(args[0])];
                if(line.contains("->beforeFilter(")) { result=early?NativeMapGate.beforeFilter((List<?>)receiver):null; }
                else if(line.contains("->emptyList(")) result=Collections.emptyList();
                else if(line.contains("->isFailure-impl(")) result=receiver==FAILURE;
                else if(line.contains("->isEmpty(")) result=((Collection<?>)receiver).isEmpty();
                else if(line.contains("->iterator(")) result=((Iterable<?>)receiver).iterator();
                else if(line.contains("->hasNext(")) result=((Iterator<?>)receiver).hasNext();
                else if(line.contains("->next(")) result=((Iterator<?>)receiver).next();
                else if(line.contains("->listOf([")) result=Arrays.asList((Object[])receiver);
                else if(line.contains("->contains(")) result=((List<?>)receiver).contains(r[reg(args[1])]);
                else if(line.contains("->collectionSizeOrDefault(")) result=((Collection<?>)receiver).size();
                else if(line.contains("-><init>(I)")) { /* ArrayList already allocated. */ }
                else if(line.contains("->toString(")) result=receiver.toString();
                else if(line.contains("->add(")) { @SuppressWarnings("unchecked") List<Object> list=(List<Object>)receiver; result=list.add(r[reg(args[1])]); }
                else throw new AssertionError("Unsupported invoke: "+line);
                continue;
            }
            throw new AssertionError("Unsupported instruction: "+line);
        }
        throw new AssertionError("no return");
    }
    public static void main(String[] args) throws Exception {
        String smali=Files.readString(Path.of(args[0]));
        int method=smali.indexOf(".method public final runInference(");
        if(method<0) throw new AssertionError("missing runInference");
        String body=smali.substring(method,smali.indexOf(".end method",method));
        String tail=body.substring(body.indexOf("    :cond_b\n"));
        List<String> code=new ArrayList<>();
        for(String line:tail.split("\n")) { line=line.trim(); if(!line.isEmpty()&&!line.startsWith("#")) code.add(line); }
        check(tail.contains("->beforeFilter(Ljava/util/List;)Ljava/util/List;"));
        List<Label> other=Collections.singletonList(Label.OTHER);
        List<String> preserved=strings(execute(code,other,true));
        check(preserved.equals(Collections.singletonList("other")));
        check(MapGateContract.fallback(NativeMapGate.extend("Directions to 10 Downing Street, London",preserved)));
        List<String> withUrl=new ArrayList<>(preserved);
        withUrl.add("has_map_url");
        List<String> urlResult=NativeMapGate.extend("https://maps.google.com/?q=London",withUrl);
        check(urlResult==withUrl && !urlResult.contains("has_intention_action") && !urlResult.contains(MapGateContract.MARKER));
        // Negative control executes the same Samsung tail with the early hook absent.
        List<?> late=execute(code,other,false);
        check(late.isEmpty());
        check(NativeMapGate.beforeFilter(late)==null);
        check(!MapGateContract.fallback(NativeMapGate.extend("Directions to London",strings(late))));
        for(Object input:Arrays.asList(Collections.emptyList(),FAILURE,Collections.singletonList(Label.IS_UNSAFE),Collections.singletonList(Label.HAS_MAP_URL),Arrays.asList(Label.OTHER,Label.HAS_INTENTION_ACTION))) check(execute(code,input,true).isEmpty());
        for(Label label:Arrays.asList(Label.HAS_INTENTION_ACTION,Label.HAS_INTENTION_QUERY)) check(execute(code,Collections.singletonList(label),true).equals(Collections.singletonList(label.toString())));
        check(execute(code,Arrays.asList(Label.HAS_INTENTION_ACTION,Label.HAS_INTENTION_QUERY),true).equals(Arrays.asList("has_intention_action","has_intention_query")));
        for(String flag:Arrays.asList("rezoss_now_nudge_native","rezoss_now_nudge_context_actions","rezoss_aios_v73_backend")) { Settings.Global.disabled=flag; check(execute(code,other,true).isEmpty()); }
        Settings.Global.disabled=null;
        Looper.main=true; check(execute(code,other,true).isEmpty()); Looper.main=false;
        System.out.println("Actual smali Map pipeline assertions="+assertions);
    }
    private static List<String> strings(List<?> values) { List<String> result=new ArrayList<>(); for(Object value:values) result.add((String)value); return result; }
}
