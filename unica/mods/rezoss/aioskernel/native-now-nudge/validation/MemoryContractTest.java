package io.mesalabs.rezoss.nudge;

import org.json.*;

/** Prompt-type schemas, untrusted content, truncation and context accounting. */
public final class MemoryContractTest {
    private static int checks;
    private static void check(boolean value){checks++;if(!value)throw new AssertionError("Memory check "+checks);}
    private static String request(String type)throws Exception {return new JSONObject().put("prompt_type",type).put("system_instruction","Use evidence; raw JSON only").put("prompt","Analyze receipt text").put("text","Tea receipt 4 EUR").toString();}
    private static void reject(String value,String input)throws Exception {try{MemoryContract.output(value,input);throw new AssertionError("Accepted invalid output "+value);}catch(Exception expected){if(expected instanceof RuntimeException&&!(expected instanceof JSONException))throw expected;checks++;}}
    public static void main(String[] args)throws Exception {
        String full=request("EXTRACT_MEMORY_SUMMARY_COLLECTION_PROMPT"),summary=request("EXTRACT_MEMORY_SUMMARY_PROMPT"),collection=request("EXTRACT_MEMORY_COLLECTION_PROMPT");
        check(MemoryContract.prompt(full).contains("Tea receipt 4 EUR"));
        try{MemoryContract.prompt(new JSONObject(full).put("text", "  ").toString());throw new AssertionError("Image-only input accepted");}catch(java.io.IOException expected){check("memory_text_unavailable".equals(expected.getMessage()));}
        check(MemoryContract.fits(15648));check(!MemoryContract.fits(15649));check(!MemoryContract.fits(0));
        String valid="{\"title\":\"Tea\",\"summary\":\"Tea receipt\",\"category\":\"Receipts\",\"tags\":[\"tea\"],\"location\":null,\"action\":null}";
        check(MemoryContract.output(valid,full).equals(valid));
        check(MemoryContract.output("{\"title\":\"Tea\",\"summary\":\"Tea receipt\"}",summary).contains("Tea"));
        check(MemoryContract.output("{\"category\":\"Receipts\"}",collection).contains("Receipts"));
        for(String bad:new String[]{"{}","{\"title\":\"Tea\"}","[]","```json\n"+valid+"\n```",valid+" commentary",valid+valid,"{\"title\":\"Tea",valid.replace("\"Tea\"","42"),valid.replace("[\"tea\"]","[42]"),valid.replace("\"Receipts\"","\"\"")})reject(bad,full);
        reject("{\"summary\":\"Tea\"}",summary);reject("{\"title\":\"Tea\"}",collection);
        reject(valid,request("COLLECTION_INSIGHT"));
        System.out.println("Memory contract: "+checks+" checks passed");
    }
}
