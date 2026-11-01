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
