package io.mesalabs.rezoss.nudge;
/** Captured echo regression and boundary cases; does not establish model accuracy. */
public final class ReplyRegressionTest {
    private static int checks;
    static void check(boolean value){checks++;if(!value)throw new AssertionError("check "+checks);}
    static void reject(String value,String prompt){try{ReplyText.validated(value,prompt);throw new AssertionError("Accepted invalid generation");}catch(IllegalArgumentException expected){checks++;}}
    public static void main(String[] args){
        String template="generate three natural responses\n<dialogue>Others: Please send the kids photos.\nOthers: Please send the beach photos.</dialogue>\nOutput only the three responses in English, separated by line breaks";
        reject("- Please send me the beach photos.\n- Please send me the kids photos.\n- Please send me the beach photos.",template);
        reject("Sure!\nSURE.\nSorry.",template);
        reject("Please send the kids photos.\nCould you clarify which ones?\nSorry, I cannot.",template);
        reject("Sure!\nSorry.",template);
        reject("- I can help with that!",template);
        reject("One\nTwo\nThree\nFour",template);
        String good="Sure, I'll look for them.\nWhich beach trip do you mean?\nSorry, I can't send them now.";
        check(ReplyText.validated(good,template).equals(good));
        String prompt=PromptAdapter.adapt(template);
        check(prompt.contains("Answer Friend's latest message as Me"));check(prompt.contains("Do not copy conversation messages"));
        check(PromptAdapter.normalizeRoles("<상대><COL> Send photos.\n<self><COL> Which trip?\nOthers: Last message says User: Hello")
            .equals("Friend: Send photos.\nMe: Which trip?\nFriend: Last message says User: Hello"));
        check(PromptAdapter.adapt(template.replace("in English,","in Hindi,")).contains("Latin-letter transliteration"));
        // Do not force the three-line contract onto an unrecognized Samsung template.
        check(ReplyText.validated("Sure.\nSorry.","other template").equals("Sure.\nSorry."));
        reject("\n",template);reject("...\n!\n?",template);
        String unicode="generate three natural responses\n<dialogue>Others: Bonjour</dialogue>\nOutput only the three responses in French, separated by line breaks";
        reject("Très bien!\nTRÈS BIEN.\nDésolé.",unicode);
        System.out.println("Reply regression: "+checks+" checks passed");
    }
}
