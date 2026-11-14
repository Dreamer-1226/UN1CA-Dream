/* SPDX-License-Identifier: GPL-3.0-or-later */
package io.mesalabs.rezoss.memory;

import java.io.ByteArrayInputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/** Tests adapter contracts, not SCS runtime execution. */
public final class IndexContractTest {
    private static int checks;
    private static void check(boolean value) {
        checks++;
        if (!value) throw new AssertionError("check " + checks);
    }
    public static void main(String[] args) throws Exception {
        for (String kind : new String[]{"memory", "memory_collection"}) {
            Element schema = DocumentBuilderFactory.newInstance().newDocumentBuilder()
                .parse(new ByteArrayInputStream(MemoryIndexAdapter.schema(kind).getBytes(StandardCharsets.UTF_8)))
                .getDocumentElement();
            String name = schema.getAttribute("name");
            check(name.substring(0, name.lastIndexOf('.')).equals("com.samsung.android.app.memory"));
            check(name.endsWith(".unica_" + kind));
            check(schema.getAttribute("useUpsert").equals("true"));
            check(schema.getAttribute("keyFieldName").equals("_id"));
            check(!schema.hasAttribute("prefKey"));
            check(schema.getAttribute("version").equals("1"));
            NodeList fields = schema.getElementsByTagName("field");
            check(fields.getLength() == 6);
            check(((Element) fields.item(0)).getAttribute("name").equals("_id"));
            check(((Element) fields.item(0)).getAttribute("isNonNull").equals("true"));
            java.util.Set<String> names = new java.util.HashSet<>();
            for (int i = 0; i < fields.getLength(); i++) check(names.add(((Element) fields.item(i)).getAttribute("name")));
            check(names.contains("title") && names.contains("content") && names.contains("deep_link"));
        }
        Method requireIds = MemoryIndexAdapter.class.getDeclaredMethod("requireIds", String.class, String[].class);
        requireIds.setAccessible(true);
        requireIds.invoke(null, "_id", new String[]{"1", "42", "9223372036854775807"});
        check(true);
        for (String invalid : new String[]{null, "", "1 OR 1=1", "-1", "1,2", "1'"}) {
            try {
                requireIds.invoke(null, "_id", new String[]{invalid});
                throw new AssertionError("invalid id accepted");
            } catch (InvocationTargetException expected) { check(expected.getCause() instanceof IllegalArgumentException); }
        }
        try {
            requireIds.invoke(null, null, new String[]{"1"});
            throw new AssertionError("unbounded deletion accepted");
        } catch (InvocationTargetException expected) { check(expected.getCause() instanceof IllegalArgumentException); }
        if (args.length == 1) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(args[0], "UTF-8")) {
                for (boolean memory : new boolean[]{true, false}) {
                    for (String input : new String[]{"sale", "%_\\", "x' OR 1=1 --"}) {
                        IndexTextQuery plan = IndexTextQuery.build(memory, input);
                        check(plan.arguments.length == (memory ? 6 : 2));
                        check(!plan.selection.contains(input));
                        writer.print(memory ? "memory" : "collection");
                        writer.print('\t');
                        writer.print(java.util.Base64.getEncoder().encodeToString(input.getBytes(StandardCharsets.UTF_8)));
                        writer.print('\t');
                        writer.print(java.util.Base64.getEncoder().encodeToString(plan.selection.getBytes(StandardCharsets.UTF_8)));
                        for (String argument : plan.arguments) {
                            writer.print('\t');
                            writer.print(java.util.Base64.getEncoder().encodeToString(argument.getBytes(StandardCharsets.UTF_8)));
                        }
                        writer.println();
                    }
                }
            }
        }
        System.out.println(checks + " Memory indexing contract checks passed");
    }
}
