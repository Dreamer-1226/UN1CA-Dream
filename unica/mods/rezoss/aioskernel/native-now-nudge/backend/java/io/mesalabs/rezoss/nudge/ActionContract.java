package io.mesalabs.rezoss.nudge;
import org.json.*;
import java.util.*;
/** Model JSON to Samsung's existing tab/pipe protocol; no keyword intent inference. */
final class ActionContract {
 static String prompt(String input){
  if(input==null||input.isEmpty()||input.length()>12000)throw new IllegalArgumentException("invalid_input");
  String message=PromptAdapter.latestIncoming(input,true);if(message==null)throw new IllegalArgumentException("no_incoming_action");
  return "Extract JSON from the message. Use these examples and copy values from the message.\n"
   +"\"send wedding photos\" -> {\"action\":\"Share Photo\",\"photo\":\"wedding\"}\n"
   +"\"schedule lunch tomorrow at noon\" -> {\"action\":\"Create Calendar\",\"type\":\"event\",\"title\":\"lunch\",\"start\":\"tomorrow at noon\"}\n"
   +"\"check calendar tomorrow\" -> {\"action\":\"View Calendar\",\"start\":\"tomorrow\"}\n"
   +"\"do not send dog photos\" -> {\"action\":\"Unsafe\"}\n"
   +"\"hello\" -> {\"action\":\"Unsafe\"}\n"
   +"Message: "+JSONObject.quote(message.replace("<|","< |").replace("|>","| >"))+"\nJSON only:\n/no_think";
 }
 static String output(String raw)throws JSONException{
  String text=ModelOutput.completion(raw).trim();JSONTokener t=new JSONTokener(text);
  if(t.nextClean()!='{')throw new JSONException("action_json_required");Map<String,String> fields=new LinkedHashMap<>();
  while(true){
   if(t.nextClean()!='"')throw new JSONException("action_key_required");String key=t.nextString('"');
   if(t.nextClean()!=':'||t.nextClean()!='"')throw new JSONException("action_string_required");String value=t.nextString('"');
   if(fields.put(key,value)!=null)throw new JSONException("duplicate_action_key");
   char c=t.nextClean();if(c=='}')break;if(c!=',')throw new JSONException("action_separator_required");
  }
  if(t.nextClean()!=0)throw new JSONException("trailing_action_content");String action=fields.remove("action");
  if("Unsafe".equals(action)&&fields.isEmpty())return "Unsafe\t";
  Set<String> allowed;
  if("Share Photo".equals(action)){allowed=new HashSet<>(Arrays.asList("photo"));if(!fields.containsKey("photo"))throw new JSONException("missing_photo");}
  else if("Create Calendar".equals(action)){allowed=new HashSet<>(Arrays.asList("type","title","start","end","location","per"));if(!fields.keySet().containsAll(Arrays.asList("type","title","start")))throw new JSONException("missing_calendar_fields");}
  else if("View Calendar".equals(action))allowed=new HashSet<>(Arrays.asList("start"));
  else throw new JSONException("unsupported_action");
  StringJoiner params=new StringJoiner("|");
  for(Map.Entry<String,String> field:fields.entrySet()){
   String v=field.getValue();if(!allowed.contains(field.getKey())||v.isEmpty()||v.length()>256||v.matches("(?s).*[\\t\\r\\n|].*"))throw new JSONException("invalid_action_parameter");
   params.add(field.getKey()+" "+v);
  }
  // SamsungRecallInference still validates grounding, supported fields and current session.
  return action+"\t"+params;
 }
}
