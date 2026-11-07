import io.mesalabs.rezoss.ai.ShadeReplyContract;
import java.util.Arrays;
import java.util.Collections;

public final class ShadeReplyContractTest {
    static final String PKG = "com.whatsapp";
    static final String A = "0|com.whatsapp|1|null|10123";
    static final String B = "0|com.whatsapp|2|null|10123";
    static final String FP = ShadeReplyContract.fingerprint("hello", 1700000000123L);
    static int checks;
    static void check(boolean result) { checks++; if (!result) throw new AssertionError("check " + checks); }
    static java.util.List<String> reply() { return Arrays.asList("Sure", "Thanks"); }
    public static void main(String[] args) {
        check(FP.length() == 64);
        check(!FP.equals(ShadeReplyContract.fingerprint("hello", 1700000000124L)));
        check(!FP.equals(ShadeReplyContract.fingerprint("hello ", 1700000000123L)));
        check(ShadeReplyContract.fingerprint("", 1) == null);
        check(ShadeReplyContract.fingerprint("hello", 0) == null);
        check(ShadeReplyContract.valid(A, PKG, FP));
        check(!ShadeReplyContract.valid(A, "com.signal", FP));
        check(!ShadeReplyContract.valid(A + "\n", PKG, FP));
        check(!ShadeReplyContract.valid(null, PKG, FP));
        String opaque = "0|com.whatsapp.w4b|1|base64Tag=\n|10536";
        String piped = "0|com.whatsapp.w4b|1|opaque|tag\r\n|10536";
        check(ShadeReplyContract.valid(opaque, "com.whatsapp.w4b", FP));
        check(ShadeReplyContract.valid(piped, "com.whatsapp.w4b", FP));
        check("com.whatsapp.w4b".equals(ShadeReplyContract.packageFromKey(opaque)));
        check("com.whatsapp.w4b".equals(ShadeReplyContract.packageFromKey(piped)));
        check(!ShadeReplyContract.valid(opaque, PKG, FP));
        check(!ShadeReplyContract.valid("0|com.whats\napp|1|tag|10536", PKG, FP));
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|1|tag|10536\n") == null);
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|id|tag|10536") == null);
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|1|tag|uid") == null);
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|1|tag") == null);
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|1||10536") != null);
        check(ShadeReplyContract.packageFromKey(null) == null);
        check(ShadeReplyContract.packageFromKey("0|com.whatsapp|1|" + new String(new char[2048]) + "|10536") == null);
        ShadeReplyContract.State opaqueState = new ShadeReplyContract.State();
        check(opaqueState.receive(opaque, "com.whatsapp.w4b", FP, 10, reply(), 20));
        opaqueState.open(opaque, "com.whatsapp.w4b", FP, "opaque1", 30);
        check(opaqueState.current(31).size() == 2);
        // Whitespace in Android's tag is identity, not formatting to normalize.
        String trimmedTag = opaque.replace("\n", "");
        opaqueState.open(trimmedTag, "com.whatsapp.w4b", FP, "opaque2", 40);
        check(opaqueState.current(41).isEmpty());
        check(!opaqueState.receive(opaque, "com.whatsapp.w4b", FP, 10, reply(), 42));
        check(opaqueState.receive(trimmedTag, "com.whatsapp.w4b", FP, 43, reply(), 44));
        opaqueState.typed(45);
        opaqueState.open(trimmedTag, "com.whatsapp.w4b", FP, "opaque2", 46);
        check(opaqueState.current(47).isEmpty());
        // A tag may itself contain another complete key plus a newline. Cache eviction
        // must compare a length-delimited identity prefix, not a raw key prefix.
        String nested = A + "\ninsideTag|10123";
        check(ShadeReplyContract.valid(nested, PKG, FP));
        ShadeReplyContract.State distinct = new ShadeReplyContract.State();
        check(distinct.receive(nested, PKG, FP, 10, reply(), 20));
        check(distinct.receive(A, PKG, FP, 30, reply(), 31));
        distinct.open(nested, PKG, FP, "nested", 40);
        check(distinct.current(41).size() == 2);
        distinct.open(null, PKG, FP, "missing", 42);
        check(distinct.current(43).isEmpty());
        ShadeReplyContract.State s = new ShadeReplyContract.State();
        check(s.receive(A, PKG, FP, 10, reply(), 20)); // before opening
        s.open(A, PKG, FP, "editor1", 30);
        check(s.current(30).size() == 2);
        s.open(A, PKG, FP, "editor1", 31);
        check(s.current(31).size() == 2);
        check(s.receive(A, PKG, FP, 40, Collections.emptyList(), 41));
        check(s.current(42).isEmpty());
        check(!s.receive(A, PKG, FP, 10, reply(), 43));
        check(s.receive(A, PKG, FP, 40, reply(), 44));
        check(!s.receive(A, PKG, FP, 40, Collections.emptyList(), 45));
        check(s.current(45).size() == 2);
        s.open(B, PKG, FP, "editor2", 50); // same field view, other chat
        check(s.current(51).isEmpty());
        check(!s.receive(A, PKG, FP, 40, reply(), 52));
        check(s.receive(B, PKG, FP, 53, reply(), 54));
        check(s.current(54).size() == 2);
        s.typed(55);
        check(s.current(55).isEmpty());
        s.open(B, PKG, FP, "editor2", 56); // deletion cannot unblock
        check(!s.receive(B, PKG, FP, 57, reply(), 58));
        check(s.current(59).isEmpty());
        String next = ShadeReplyContract.fingerprint("next incoming", 1700000000999L);
        s.open(B, PKG, next, "editor3", 60);
        check(s.receive(B, PKG, next, 61, reply(), 62));
        check(s.current(62).size() == 2);
        s.close(63);
        s.open(B, PKG, next, "editor4", 64);
        check(!s.receive(B, PKG, next, 61, reply(), 65));
        check(s.current(65).isEmpty());
        check(s.receive(B, PKG, next, 66, reply(), 67));
        s.open(B, PKG, next, "newToken", 68);
        check(s.current(69).isEmpty());
        check(!s.receive(B, PKG, next, 66, reply(), 70));
        check(s.receive(B, PKG, next, 71, reply(), 72));
        check(s.current(60_000_000_072L).isEmpty());
        check(!s.receive(B, PKG, next, 71, reply(), 60_000_000_072L));
        check(!s.receive(B, PKG, next, 90, reply(), 80));
        s.open(B, PKG, next, "", 81);
        check(s.current(82).isEmpty());
        check(!s.receive(B, "com.signal", next, 83, reply(), 84));
        check(!s.receive(B, PKG, null, 83, reply(), 84));
        ShadeReplyContract.State bounded = new ShadeReplyContract.State();
        for (int i = 0; i < 16; i++) check(bounded.receive("0|com.whatsapp|" + i + "|null|10123", PKG, FP, 100, reply(), 101));
        check(!bounded.receive("0|com.whatsapp|16|null|10123", PKG, FP, 100, reply(), 101));
        bounded.open(A, PKG, FP, "bounded", 102);
        check(bounded.receive(A, PKG, FP, 103, Collections.emptyList(), 104));
        check(!bounded.receive(A, PKG, FP, 100, reply(), 105));
        check(bounded.current(105).isEmpty());
        ShadeReplyContract.State changed = new ShadeReplyContract.State();
        changed.open(A, PKG, FP, "samefield", 1);
        check(changed.receive(A, PKG, FP, 10, Collections.emptyList(), 11));
        check(changed.receive(A, PKG, FP, 10, reply(), 12));
        check(changed.current(13).size() == 2);
        check(changed.receive(A, PKG, next, 20, Collections.emptyList(), 21));
        check(changed.current(22).isEmpty());
        check(!changed.receive(A, PKG, FP, 10, reply(), 23));
        check(!changed.receive(A, PKG, FP, 20, reply(), 24));
        check(changed.receive(A, PKG, FP, 30, Collections.emptyList(), 31));
        check(!changed.receive(A, PKG, next, 20, reply(), 32));
        check(changed.receive(A, PKG, FP, 30, reply(), 33));
        check(changed.current(34).size() == 2);
        System.out.println("ShadeReplyContract: " + checks + " checks passed");
    }
}
