import android.content.BroadcastReceiver;
import android.content.Intent;
import android.inputmethodservice.InputMethodService;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.inputmethod.EditorInfo;
import io.mesalabs.rezoss.ai.ShadeReplyContract;
import io.mesalabs.rezoss.ai.ShadeReplyKeyboard;
import java.util.ArrayList;
import java.util.Arrays;

public final class ShadeReplyKeyboardTest {
    private static final String PKG="com.whatsapp", A="0|com.whatsapp|1|null|10123", B="0|com.whatsapp|2|null|10123";
    private static final String FP=ShadeReplyContract.fingerprint("hello",1700000000123L);
    private static int checks;
    public static final class Receiver extends BroadcastReceiver {
        public Object lastItem; public int renders, clears; public boolean renderKeep, clearKeep;
        public void t(Intent intent){renders++;renderKeep=ShadeReplyKeyboard.keep();lastItem=new Object();ShadeReplyKeyboard.tagItem(lastItem);}
        public void q(Intent intent){clears++;clearKeep=ShadeReplyKeyboard.keep();}
    }
    private static void check(boolean condition){checks++;if(!condition)throw new AssertionError("check "+checks);}
    private static EditorInfo info(String key,String token){
        EditorInfo info=new EditorInfo();info.packageName="com.android.systemui";info.extras=new Bundle();
        info.extras.putString(ShadeReplyContract.KEY,key);info.extras.putString(ShadeReplyContract.PACKAGE,PKG);
        info.extras.putString(ShadeReplyContract.FINGERPRINT,FP);info.extras.putString(ShadeReplyContract.TOKEN,token);return info;
    }
    private static void start(InputMethodService ime,String key,String token){ime.info=info(key,token);ShadeReplyKeyboard.start(ime,ime.info);}
    private static void deliver(Receiver receiver,InputMethodService ime,String key,long started){
        Intent event=new Intent("com.samsung.android.intent.action.SUGGESTED_REPLIES");
        event.putExtra(ShadeReplyContract.BRIDGE,true).putExtra(ShadeReplyContract.KEY,key).putExtra(ShadeReplyContract.PACKAGE,PKG)
            .putExtra(ShadeReplyContract.FINGERPRINT,FP).putExtra(ShadeReplyContract.STARTED,started);
        event.putStringArrayListExtra("SUGGESTIONS",new ArrayList<>(Arrays.asList("Sure","Thanks")));
        check(ShadeReplyKeyboard.consume(receiver,event,ime));
    }
    private static Bundle command(String token,boolean typed){Bundle b=new Bundle();b.putString(ShadeReplyContract.TOKEN,token);b.putBoolean(ShadeReplyContract.BLOCKED,typed);return b;}
    public static void main(String[] args){
        Receiver receiver=new Receiver();InputMethodService ime=new InputMethodService();
        // Sender UID and signature are both required before a pre-editor result can be cached.
        receiver.sender=999;deliver(receiver,ime,A,90);check(receiver.renders==0);
        start(ime,A,"first");check(receiver.renders==0);
        receiver.sender=123;android.content.pm.PackageManager.signature=-1;
        deliver(receiver,ime,A,SystemClock.elapsedRealtimeNanos());check(receiver.renders==0);
        android.content.pm.PackageManager.signature=0;
        deliver(receiver,ime,A,SystemClock.elapsedRealtimeNanos());check(receiver.renders==1);
        Object first=receiver.lastItem;check(ShadeReplyKeyboard.isBridgeItem(first));check(ShadeReplyKeyboard.allowClick(first));
        // An invalidation for another field token cannot close the live editor.
        ShadeReplyKeyboard.command("rezoss.shade.invalidate",command("wrong",false));
        check(ShadeReplyKeyboard.active());check(ShadeReplyKeyboard.allowClick(first));
        // Same rendered string in another notification cannot make an old chip valid.
        start(ime,B,"second");check(!ShadeReplyKeyboard.allowClick(first));
        long newer=SystemClock.elapsedRealtimeNanos();deliver(receiver,ime,B,newer);
        Object second=receiver.lastItem;check(second!=first);check(ShadeReplyKeyboard.allowClick(second));
        // A new token in the same chat revokes old chip tickets and late generation results.
        start(ime,B,"third");check(!ShadeReplyKeyboard.allowClick(second));
        deliver(receiver,ime,B,newer);check(!ShadeReplyKeyboard.keep());
        long current=SystemClock.elapsedRealtimeNanos();deliver(receiver,ime,B,current);
        Object third=receiver.lastItem;check(ShadeReplyKeyboard.allowClick(third));
        // Typing, deleting and restarting with identical scope must not restore old suggestions.
        ime.text="x";ShadeReplyKeyboard.selection();check(!ShadeReplyKeyboard.allowClick(third));
        ime.text="";start(ime,B,"third");deliver(receiver,ime,B,SystemClock.elapsedRealtimeNanos());
        check(!ShadeReplyKeyboard.keep());
        ShadeReplyKeyboard.command("rezoss.shade.invalidate",command("third",false));check(!ShadeReplyKeyboard.active());
        // A genuinely new notification can be cached before its first editor connection.
        long cached=SystemClock.elapsedRealtimeNanos();deliver(receiver,ime,A,cached);int before=receiver.renders;
        start(ime,A,"fourth");check(receiver.renders==before+1);check(ShadeReplyKeyboard.allowClick(receiver.lastItem));
        // Missing identity closes the bridge, and old-chip clicks stay rejected.
        Object fourth=receiver.lastItem;ime.info=new EditorInfo();ime.info.packageName="com.android.systemui";
        ShadeReplyKeyboard.start(ime,ime.info);check(!ShadeReplyKeyboard.active());check(!ShadeReplyKeyboard.allowClick(fourth));
        // The scheduled refresh also removes chips after the generation TTL.
        long fresh=SystemClock.elapsedRealtimeNanos();deliver(receiver,ime,A,fresh);start(ime,A,"expiry");
        Object expiring=receiver.lastItem;check(ShadeReplyKeyboard.allowClick(expiring));
        check(receiver.renderKeep);
        int renders=receiver.renders;SystemClock.clock+=1_000_000_000L;android.os.Handler.runDelayed();
        check(receiver.renders==renders);check(ShadeReplyKeyboard.allowClick(expiring));
        // The same-replies early return must still re-arm the next expiration check.
        int clears=receiver.clears;SystemClock.clock+=60_000_000_001L;android.os.Handler.runDelayed();
        check(receiver.clears==clears+1);check(!ShadeReplyKeyboard.allowClick(expiring));check(!receiver.clearKeep);
        System.out.println("ShadeReplyKeyboard production adapter: "+checks+" checks passed");
    }
}
