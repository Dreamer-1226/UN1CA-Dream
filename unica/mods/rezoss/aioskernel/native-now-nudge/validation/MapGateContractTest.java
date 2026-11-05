import io.mesalabs.rezoss.ai.MapGateContract;
import java.util.*;

public final class MapGateContractTest {
    enum Label {
        OTHER("other"), UNSAFE("is_unsafe"), ACTION("has_intention_action"), QUERY("has_intention_query");
        final String text; Label(String text) { this.text = text; }
        @Override public String toString() { return text; }
    }
    private static int checks;
    private static void check(boolean result) { checks++; if (!result) throw new AssertionError("check " + checks); }
    public static void main(String[] args) {
        List<Label> raw = Collections.singletonList(Label.OTHER);
        check(MapGateContract.beforeFilter(raw, true, true).equals(Collections.singletonList("other")));
        check(raw.size() == 1 && raw.get(0) == Label.OTHER);
        check(MapGateContract.beforeFilter(raw, false, true) == null);
        check(MapGateContract.beforeFilter(raw, true, false) == null);
        check(MapGateContract.beforeFilter(null, true, true) == null);
        check(MapGateContract.beforeFilter(Collections.emptyList(), true, true) == null);
        check(MapGateContract.beforeFilter(Collections.singletonList("other"), true, true) == null);
        check(MapGateContract.beforeFilter(Collections.singletonList(null), true, true) == null);
        for (List<Label> labels : Arrays.asList(Arrays.asList(Label.UNSAFE), Arrays.asList(Label.ACTION),
                Arrays.asList(Label.QUERY), Arrays.asList(Label.OTHER, Label.UNSAFE),
                Arrays.asList(Label.OTHER, Label.ACTION), Arrays.asList(Label.OTHER, Label.OTHER)))
            check(MapGateContract.beforeFilter(labels, true, true) == null);
        List<String> other = Collections.singletonList("other");
        String input = "Directions to 10 Downing Street, London";
        List<String> candidate = MapGateContract.extend(input, other, true, true);
        check(candidate != other); check(other.size() == 1); check(MapGateContract.fallback(candidate));
        check(MapGateContract.extend(input, candidate, true, true) == candidate);
        check(MapGateContract.extend(input, other, false, true) == other);
        check(MapGateContract.extend(input, other, true, false) == other);
        check(MapGateContract.extend(null, other, true, true) == other);
        check(MapGateContract.extend(" ", other, true, true) == other);
        check(MapGateContract.extend(new String(new char[12001]), other, true, true) == other);
        for (List<String> stock : Arrays.asList(Collections.<String>emptyList(),
                Arrays.asList("is_unsafe"), Arrays.asList("other", "is_unsafe"),
                Arrays.asList("has_intention_query"), Arrays.asList("has_intention_action"),
                Arrays.asList("other", "has_map_url"), Arrays.asList("unknown"))) {
            check(MapGateContract.extend(input, stock, true, true) == stock);
            check(!MapGateContract.fallback(stock));
        }
        check(MapGateContract.extend(input, null, true, true) == null);
        check(!MapGateContract.fallback(Arrays.asList("other", "has_intention_action", MapGateContract.MARKER, "is_unsafe")));
        check(!MapGateContract.fallback(Arrays.asList(MapGateContract.MARKER, MapGateContract.MARKER, "other")));
        Map<String,String> location = Collections.singletonMap("location", "10 Downing Street, London");
        check(MapGateContract.mapAction("Browse Location", location));
        // Actual intent is decided downstream by the model, never by words in this gate.
        check(MapGateContract.extend("hello", other, true, true) != other);
        for (String action : Arrays.asList("Call", "Mail", "Set Reminder", "Create Calendar", "Share Photo", "Unsafe", "Save Place", "view_map"))
            check(!MapGateContract.mapAction(action, location));
        check(!MapGateContract.mapAction("Browse Location", null));
        check(!MapGateContract.mapAction("Browse Location", Collections.emptyMap()));
        check(!MapGateContract.mapAction("Browse Location", Collections.singletonMap("location", " ")));
        check(!MapGateContract.mapAction("Browse Location", Collections.singletonMap("location", "Paris\nLondon")));
        check(!MapGateContract.mapAction("Browse Location", Collections.singletonMap("location", "Paris\u200b")));
        check(!MapGateContract.mapAction("Browse Location", Collections.singletonMap("location", new String(new char[257]))));
        Map<String,Object> extra = new HashMap<>(); extra.put("location", "London"); extra.put("title", "x");
        check(!MapGateContract.mapAction("Browse Location", extra));
        extra.clear(); extra.put("location", 123); check(!MapGateContract.mapAction("Browse Location", extra));
        System.out.println("MapGateContract: " + checks + " checks passed");
    }
}
