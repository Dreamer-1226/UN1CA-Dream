package io.mesalabs.rezoss.nudge;
import io.mesalabs.rezoss.ai.RecallPrediction;
import io.mesalabs.rezoss.ai.RecallSession;
/** Wire/protocol tests; actual model quality requires a separate direct replay. */
public final class GenerationContractTest {
 static int checks;
 static void check(boolean value){checks++;if(!value)throw new AssertionError("check "+checks);}
 static void reject(ContextReplyContract c,String value)throws Exception{try{c.output(value);throw new AssertionError("accepted invalid response");}catch(org.json.JSONException|IllegalArgumentException expected){checks++;}}
 static String template(String text){return "generate three natural responses\n<dialogue>Others: "+text+"</dialogue>\nOutput only the three responses in English, separated by line breaks";}
 public static void main(String[]args)throws Exception{
  ContextReplyContract c=new ContextReplyContract(template("Please send the beach photos"));
  String good="{\"negative\":\"Sorry, I cannot share them.\",\"positive\":\"Sure, I'll look for them.\",\"neutral\":\"Which beach trip do you mean?\"}";
  check(c.output(good+"<|im_end|>\n").equals("Sure, I'll look for them.\nWhich beach trip do you mean?\nSorry, I cannot share them."));
  reject(c,"I can help with that!");reject(c,"{\"positive\":\"Sure\"}");
  reject(c,good.replace("\"negative\":","\"positive\":"));
  reject(c,good.substring(0,good.length()-1)+",\"extra\":\"x\"}");
  reject(c,good+"garbage");reject(c,good.replace("Sure, I'll look for them.","Please send the beach photos"));
  reject(c,good.replace("Sorry, I cannot share them.","Sure, I'll look for them."));
  reject(c,good.replace("Which beach trip do you mean?","neutral"));
  reject(c,good.replace("Which beach trip do you mean?","Line one\\nline two"));
  String action="Share Photo\tphoto beach";
  check(RecallPrediction.parse("Please send the beach photos",action+"<|im_end|>")==null);
  check(RecallPrediction.parse("Please send the beach photos",ModelOutput.completion(action+"<|im_end|>\n")).parameters.equals("photo beach"));
  check(ModelOutput.completion("Unsafe\t<|im_end|>\n").equals("Unsafe\t"));
  check(ModelOutput.completion("View Calendar\t").equals("View Calendar\t"));
  try{ModelOutput.completion("Share Photo\tphoto <|im_end|>beach");throw new AssertionError();}catch(IllegalArgumentException expected){checks++;}
  check(c.prompt.contains("positive, neutral, negative"));check(c.prompt.contains("Friend's most recent message"));
  check(ActionContract.output("{\"action\":\"Share Photo\",\"photo\":\"beach\"}<|im_end|>").equals("Share Photo\tphoto beach"));
  check(ActionContract.output("{\"action\":\"Unsafe\"}").equals("Unsafe\t"));
  check(RecallPrediction.parse("Please send beach photos",ActionContract.output("{\"action\":\"Share Photo\",\"photo\":\"mountain\"}"))!=null);
  for(String query:new String[]{"enfant","enfants","children","enftas"})check(RecallPrediction.parse("photos des enfant svp", "Share Photo\tphoto "+query)!=null);
  check(RecallPrediction.parse("photos", "Share Photo\tphoto children\u0000")==null);
  check(RecallPrediction.parse("dinner tomorrow", "Create Calendar\ttype event|title lunch|start tomorrow")==null);
  check(PromptAdapter.latestIncoming("Others: send beach photos\nUser: Already sent",true)==null);
  check(PromptAdapter.latestIncoming("Others: send kids photos\nOthers: send beach photos",true).equals("send beach photos"));
  check(ActionContract.prompt("Others: send kids photos\nOthers: send beach photos").contains("Message: \"send beach photos\""));
  String[][] textActions={
   {"Directions to 10 Downing Street, London","{\"action\":\"Browse Location\",\"location\":\"10 Downing Street, London\"}"},
   {"Call +33 1 42 68 53 00","{\"action\":\"Call\",\"number\":\"+33 1 42 68 53 00\"}"},
   {"Email alex@example.com","{\"action\":\"Mail\",\"mail\":\"alex@example.com\"}"},
   {"Remind me to buy milk tomorrow at noon","{\"action\":\"Set Reminder\",\"title\":\"buy milk\",\"start\":\"tomorrow at noon\"}"},
   {"Remind me to buy milk","{\"action\":\"Set Reminder\",\"title\":\"buy milk\"}"}
  };
  for(String[] example:textActions){
   String wire=ActionContract.output(example[1]);
   RecallPrediction prediction=RecallPrediction.parse(example[0],wire);
   check(prediction!=null);
   RecallSession.put(example[0],prediction,200);
   check(RecallSession.consume(example[0]+" <Action> "+prediction.action+" <상대> Others",100).equals(prediction.parameters));
   check(RecallSession.consume(example[0]+" <Action> "+prediction.action,100).isEmpty());
  }
  check(RecallPrediction.parse("Directions to London",ActionContract.output(textActions[0][1]))==null);
  check(RecallPrediction.parse("Call 12345",ActionContract.output(textActions[1][1]))==null);
  check(RecallPrediction.parse("Email other@example.com",ActionContract.output(textActions[2][1]))==null);
  check(RecallPrediction.parse("Call 12",ActionContract.output("{\"action\":\"Call\",\"number\":\"12\"}"))==null);
  check(RecallPrediction.parse("Call tel:12345",ActionContract.output("{\"action\":\"Call\",\"number\":\"tel:12345\"}"))==null);
  check(RecallPrediction.parse("Email alex@localhost",ActionContract.output("{\"action\":\"Mail\",\"mail\":\"alex@localhost\"}"))==null);
  check(RecallPrediction.parse("Call Alice","Call\tname Alice")==null);
  check(RecallPrediction.parse("Email alex@example.com?subject=x","Mail\tmail alex@example.com?subject=x")==null);
  check(RecallPrediction.parse("Remind me to buy milk tomorrow","Set Reminder\ttitle buy eggs|start tomorrow")==null);
  check(RecallPrediction.parse("Adresse : 12 rue de Rivoli, Paris","Browse Location\tlocation 12 rue de Rivoli, Paris")!=null);
  check(RecallPrediction.parse("Rappelle-moi acheter du lait demain","Set Reminder\ttitle acheter du lait|start demain")!=null);
  java.util.Map<String,java.util.Set<String>> schema=new java.util.LinkedHashMap<>();
  schema.put("Call",java.util.Collections.singleton("number"));
  RecallPrediction.addMailSchema(schema);
  check(schema.get("Mail").equals(java.util.Collections.singleton("mail")));
  check(schema.get("Call").equals(java.util.Collections.singleton("number")));
  schema.put("Mail",java.util.Collections.singleton("existing"));
  RecallPrediction.addMailSchema(schema);
  check(schema.get("Mail").equals(java.util.Collections.singleton("existing")));
  try{ActionContract.prompt("Others: Call 12345\nUser: Already called");throw new AssertionError("stale action");}catch(IllegalArgumentException expected){checks++;}
  for(String invalid:new String[]{
   "{\"action\":\"Browse Location\"}",
   "{\"action\":\"Call\",\"name\":\"Alice\"}",
   "{\"action\":\"Mail\",\"email\":\"alex@example.com\"}",
   "{\"action\":\"Set Reminder\",\"start\":\"tomorrow\"}",
   "{\"action\":\"Set Reminder\",\"title\":\"buy milk\",\"location\":\"Paris\"}",
   "{\"action\":\"Browse Location\",\"location\":\"Paris|number 12345\"}",
   "{\"action\":\"Mail\",\"mail\":\"a@example.com\",\"mail\":\"b@example.com\"}",
   "{\"action\":\"Send Payment\",\"account\":\"12345\"}"}){
   try{ActionContract.output(invalid);throw new AssertionError("accepted invalid text action");}catch(org.json.JSONException expected){checks++;}
  }
  for(String invalid:new String[]{"{\"action\":\"Unsafe\",\"photo\":\"beach\"}","{\"action\":\"Share Photo\"}","{\"action\":\"Unknown\"}","{\"action\":\"Share Photo\",\"photo\":\"beach\",\"photo\":\"kids\"}"}){
   try{ActionContract.output(invalid);throw new AssertionError("accepted invalid action");}catch(org.json.JSONException expected){checks++;}
  }
  check(c.promptForTone(0).contains("if you agree"));check(c.promptForTone(1).contains("need clarification"));check(c.promptForTone(2).contains("brief refusal"));
  check(c.lines(new String[]{"Sure, I'll look for them.","Which photos do you mean?","Sorry, I cannot send them."}).split("\\R").length==3);
  String fr=template("Envoyez les photos svp").replace("in English,", "in French,");
  ContextReplyContract french=new ContextReplyContract(fr);
  for(int tone=0;tone<3;tone++){
   check(french.promptForTone(tone).contains("Answer in French."));
   check(!french.promptForTone(tone).contains("transliteration"));
   check(!french.promptForTone(tone).contains("writing system"));
  }
  check(french.prompt.contains("Latin transliteration"));
  check(!PromptAdapter.adaptLocal(fr).contains("transliteration"));
  check(PromptAdapter.adapt(fr).contains("transliteration"));
  String turns="[{\"text\":\"Bonjour\"}]";
  for(boolean summary:new boolean[]{false,true}){
   check(!LocalFormat.prompt(turns,summary,true).contains("writing system"));
   check(!LocalFormat.prompt(turns,summary,true).contains("Mirror mixed"));
   check(LocalFormat.prompt(turns,summary,false).contains("Mirror mixed"));
  }
  System.out.println("Generation contract: "+checks+" checks passed");
 }
}
