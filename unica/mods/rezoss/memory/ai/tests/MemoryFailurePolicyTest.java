/* SPDX-License-Identifier: GPL-3.0-or-later */
package io.mesalabs.rezoss.memory;
import java.util.concurrent.*;
public final class MemoryFailurePolicyTest {
    static int checked;
    static void expect(boolean expected, Throwable error) {
        if (MemoryFailurePolicy.eligible(error) != expected) throw new AssertionError(error);
        checked++;
    }
    public static void main(String[] args) throws Throwable {
        expect(true,new IllegalStateException("AUTH_ERROR 800010 SAK authentication failed"));
        expect(true,new IllegalStateException("invalid_grant Invalid JWT Signature"));
        expect(true,new IllegalStateException("401 UNAUTHENTICATED"));
        expect(true,new TimeoutException("request timed out"));
        expect(true,new java.net.SocketTimeoutException());
        expect(true,new IllegalStateException("service unavailable"));
        expect(true,new RuntimeException("wrapper",new IllegalStateException("service not found")));
        expect(false,new CancellationException("auth_error"));
        expect(false,new RuntimeException("auth_error",new CancellationException("user cancelled")));
        expect(false,new RuntimeException("auth_error",new InterruptedException()));
        expect(false,new IllegalStateException("safety refusal auth_error"));
        expect(false,new IllegalStateException("blocked content service unavailable"));
        expect(false,new IllegalStateException("content_filter timeout"));
        expect(false,new IllegalArgumentException("invalid JSON"));
        expect(false,new RuntimeException("unknown error"));
        expect(false,null);
        expect(false,new IllegalStateException());
        expect(true,new IllegalStateException("401 Unauthorized"));
        expect(true,new kotlinx.coroutines.TimeoutCancellationException());
        Throwable observed=new IllegalStateException("401 UNAUTHENTICATED CREDENTIALS_MISSING");
        try { MemoryFailurePolicy.throwIfEligible(observed); throw new AssertionError("Vertex auth cause lost"); }
        catch(Throwable actual) { if(actual!=observed)throw new AssertionError("Wrong preserved cause",actual); checked++; }
        MemoryFailurePolicy.throwIfEligible(new IllegalStateException("safety refusal")); checked++;
        System.out.println("Memory fallback policy: "+checked+" checks passed");
    }
}
