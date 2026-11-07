// SPDX-License-Identifier: Apache-2.0
package com.rezoss.portraitpairprobe;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.AttributionSource;
import android.graphics.ImageFormat;
import android.hardware.camera2.*;
import android.hardware.camera2.params.OutputConfiguration;
import android.hardware.camera2.params.SessionConfiguration;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Size;
import org.json.JSONArray;
import org.json.JSONObject;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.security.MessageDigest;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/** Root-only temporary diagnostic. Never modifies server permissions or calibration. */
public final class PrivilegedProbe {
    private static final String MAIN = "54", AUX = "52", LOGICAL = "20";
    private final CountDownLatch done = new CountDownLatch(1);
    private final Map<String, Set<Long>> images = new LinkedHashMap<>();
    private final List<ImageReader> readers = new ArrayList<>();
    private final Set<Long> pairedResults = new HashSet<>();
    private Handler handler;
    private CameraDevice camera;
    private CameraCaptureSession session;
    private boolean stopped;
    private boolean inApplication;
    private int results;

    private static synchronized void emit(String event, Object... fields) {
        try {
            JSONObject row = new JSONObject().put("event", event);
            for (int i = 0; i < fields.length; i += 2) row.put(fields[i].toString(), fields[i+1]);
            System.out.println(row); System.out.flush();
            android.util.Log.i("PortraitPairPrivileged",row.toString());
        } catch (Exception e) { System.err.println(e); }
    }
    private void fail(String stage, Throwable error) {
        emit("error", "stage", stage, "type", error.getClass().getName(), "message", String.valueOf(error.getMessage()));
        stop(stage);
    }
    private static String hash(byte[] b) throws Exception {
        StringBuilder s = new StringBuilder();
        for (byte n : MessageDigest.getInstance("SHA-256").digest(b)) s.append(String.format(Locale.ROOT,"%02x",n&255));
        return s.toString();
    }
    @SuppressWarnings({"rawtypes", "unchecked"})
    private static void inventory(CameraManager manager, String id) throws Exception {
        CameraCharacteristics c = manager.getCameraCharacteristics(id);
        emit("camera", "id", id, "physical_ids", new JSONArray(c.getPhysicalCameraIds()),
            "focal_lengths", Arrays.toString(c.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)),
            "active_array", String.valueOf(c.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE)),
            "sync_type", String.valueOf(c.get(CameraCharacteristics.LOGICAL_MULTI_CAMERA_SENSOR_SYNC_TYPE)));
        for (CameraCharacteristics.Key key : c.getKeys()) {
            String name = key.getName();
            if (!name.contains("dualCalibration") && !name.endsWith("rawSensorInfo")) continue;
            Object v = c.get(key);
            if (v instanceof byte[]) emit("calibration_blob", "id", id, "key", name, "bytes", ((byte[])v).length, "sha256", hash((byte[])v));
            else emit("characteristic", "id", id, "key", name, "value", v instanceof int[] ? Arrays.toString((int[])v) : String.valueOf(v));
        }
        // Samsung declares these keys in its app, so getKeys() need not enumerate them.
        for(String name:new String[]{"samsung.android.logicalMultiCamera.dualCalibration",
                "samsung.android.logicalMultiCamera.dualCalibrationT_W",
                "samsung.android.logicalMultiCamera.dualCalibrationT2_T1"}) {
            try {
                byte[] data=c.get(new CameraCharacteristics.Key<byte[]>(name,byte[].class));
                if(data==null) emit("explicit_calibration_key","id",id,"key",name,"present",false);
                else emit("explicit_calibration_key","id",id,"key",name,"present",true,"bytes",data.length,"sha256",hash(data));
            } catch(IllegalArgumentException missing) { emit("explicit_calibration_key","id",id,"key",name,"present",false,"error",String.valueOf(missing.getMessage())); }
        }
    }
    private void start(CameraManager manager) {
        try {
            CameraCharacteristics logical = manager.getCameraCharacteristics(LOGICAL);
            if (!logical.getPhysicalCameraIds().containsAll(Arrays.asList(MAIN,AUX)))
                throw new IllegalStateException("Requested pair absent from logical physical IDs");
            StreamConfigurationMap a = manager.getCameraCharacteristics(MAIN).get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
            StreamConfigurationMap b = manager.getCameraCharacteristics(AUX).get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
            List<Size> common = new ArrayList<>();
            Set<Size> other = new HashSet<>(Arrays.asList(b.getOutputSizes(ImageFormat.YUV_420_888)));
            for (Size s : a.getOutputSizes(ImageFormat.YUV_420_888))
                if (other.contains(s) && s.getWidth() >= 640 && s.getHeight() >= 480 && s.getWidth() <= 1920 && s.getHeight() <= 1080) common.add(s);
            common.sort(Comparator.comparingLong(s -> (long)s.getWidth()*s.getHeight()));
            if (common.isEmpty()) throw new IllegalStateException("No common bounded YUV size");
            Size size = common.get(0);
            emit("chosen_size", "size", size.toString(), "logical_zoom", 10);
            List<OutputConfiguration> outputs = new ArrayList<>();
            for (String id : new String[]{MAIN,AUX}) {
                images.put(id,new HashSet<>());
                ImageReader reader = ImageReader.newInstance(size.getWidth(),size.getHeight(),ImageFormat.YUV_420_888,3);
                reader.setOnImageAvailableListener(r -> {
                    try (Image image = r.acquireNextImage()) {
                        if (!stopped && image != null) {
                            Set<Long> stamps = images.get(id);
                            if (stamps.size() < 240) stamps.add(image.getTimestamp());
                            if (stamps.size() <= 5) emit("image", "id",id,"timestamp_ns",image.getTimestamp());
                        }
                    } catch (Exception e) { if (!stopped) fail("image",e); }
                },handler);
                readers.add(reader);
                OutputConfiguration output = new OutputConfiguration(reader.getSurface());
                output.setPhysicalCameraId(id); outputs.add(output);
            }
            manager.openCamera(LOGICAL,new CameraDevice.StateCallback() {
                @Override public void onOpened(CameraDevice d) {
                    if (stopped) { d.close(); return; } camera=d;
                    emit("opened", "id",d.getId());
                    try {
                        SessionConfiguration config = new SessionConfiguration(SessionConfiguration.SESSION_REGULAR,outputs,
                            task -> handler.post(task),new CameraCaptureSession.StateCallback() {
                                @Override public void onConfigured(CameraCaptureSession s) {
                                    if (stopped) { s.close(); return; } session=s;
                                    try {
                                        CaptureRequest.Builder q=camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                                        for (ImageReader r : readers) q.addTarget(r.getSurface());
                                        q.set(CaptureRequest.CONTROL_ZOOM_RATIO,10f);
                                        s.setRepeatingRequest(q.build(),new CameraCaptureSession.CaptureCallback() {
                                            @Override public void onCaptureCompleted(CameraCaptureSession cs,CaptureRequest rq,TotalCaptureResult result) {
                                                if (stopped) return; results++;
                                                Map<String,CaptureResult> physical=result.getPhysicalCameraResults();
                                                if (physical.containsKey(MAIN)&&physical.containsKey(AUX)) pairedResults.add(result.getFrameNumber());
                                                if (results<=5) {
                                                    emit("result","frame",result.getFrameNumber(),"physical_results",new JSONArray(physical.keySet()));
                                                    for (Map.Entry<String,CaptureResult> p:physical.entrySet()) emit("physical_result","id",p.getKey(),
                                                        "timestamp_ns",String.valueOf(p.getValue().get(CaptureResult.SENSOR_TIMESTAMP)),
                                                        "focal_length",String.valueOf(p.getValue().get(CaptureResult.LENS_FOCAL_LENGTH)),
                                                        "crop",String.valueOf(p.getValue().get(CaptureResult.SCALER_CROP_REGION)));
                                                }
                                            }
                                            @Override public void onCaptureFailed(CameraCaptureSession cs,CaptureRequest rq,CaptureFailure f) {
                                                if (!stopped) { emit("capture_failed","reason",f.getReason()); stop("capture_failed"); }
                                            }
                                        },handler);
                                        emit("stream_request","zoom",10,"template","PREVIEW");
                                    } catch(Exception e) { fail("request",e); }
                                }
                                @Override public void onConfigureFailed(CameraCaptureSession s) { emit("configure_failed"); stop("configure_failed"); }
                            });
                        camera.createCaptureSession(config);
                    } catch(Exception e) { fail("session",e); }
                }
                @Override public void onDisconnected(CameraDevice d) { d.close(); stop("disconnected"); }
                @Override public void onError(CameraDevice d,int code) { d.close(); emit("device_error","code",code); stop("device_error"); }
            },handler);
        } catch(Exception e) { fail("stream_setup",e); }
    }
    private void stop(String reason) {
        if (stopped) return; stopped=true;
        if (session!=null) session.close();
        if (camera!=null) camera.close();
        for (ImageReader r:readers) r.close();
        Set<Long> a=images.getOrDefault(MAIN,Collections.emptySet()),b=images.getOrDefault(AUX,Collections.emptySet());
        Set<Long> both=new HashSet<>(a); both.retainAll(b);
        emit("summary","reason",reason,"main_images",a.size(),"aux_images",b.size(),"results",results,
            "exact_timestamp_matches",both.size(),"frames_with_both_physical_results",pairedResults.size(),
            "calibration_validated",false,"depth_validated",false);
        done.countDown();
        if(inApplication) handler.getLooper().quitSafely();
    }
    /** Entry for an authorized temporary attachment to the real Camera process. */
    public static void runInApplication(Context context) {
        if(!"com.sec.android.app.camera".equals(context.getPackageName()) ||
                android.os.Process.myUid()!=context.getApplicationInfo().uid)
            throw new SecurityException("Requires the real Samsung Camera application context and UID");
        PrivilegedProbe probe=new PrivilegedProbe(); probe.inApplication=true;
        HandlerThread worker=new HandlerThread("inprocess-portrait-pair"); worker.start();
        probe.handler=new Handler(worker.getLooper());
        probe.handler.post(() -> {
            emit("begin","route","real_camera_process","uid",android.os.Process.myUid(),
                "pid",android.os.Process.myPid(),"context_package",context.getOpPackageName());
            CameraManager manager=(CameraManager)context.getSystemService(Context.CAMERA_SERVICE);
            try { for(String id:new String[]{LOGICAL,MAIN,AUX}) inventory(manager,id); }
            catch(Exception e) { probe.fail("inventory",e); return; }
            probe.handler.postDelayed(() -> probe.stop("timeout"),15000);
            probe.start(manager);
        });
    }
    public static void main(String[] args) throws Exception {
        if(android.os.Process.myUid()!=0) throw new SecurityException("Run this temporary diagnostic as root");
        Looper.prepareMainLooper();
        Class<?> at=Class.forName("android.app.ActivityThread");
        Method main=at.getDeclaredMethod("systemMain"); main.setAccessible(true);
        Object thread=main.invoke(null);
        Method contextMethod=at.getDeclaredMethod("getSystemContext"); contextMethod.setAccessible(true);
        Context context=(Context)contextMethod.invoke(thread);
        int forwardingPid=-1;
        for(String arg:args) if(arg.startsWith("--camera-attribution-pid=")) forwardingPid=Integer.parseInt(arg.substring(arg.indexOf('=')+1));
        final int clientPid=forwardingPid;
        if(Arrays.asList(args).contains("--camera-uid-context") || clientPid>0) {
            // Run as the actual installed Samsung Camera UID; no APK replacement or
            // service allowlist mutation. Root is used only to create this diagnostic.
            context=context.createPackageContext("com.sec.android.app.camera",0);
            int uid=context.getApplicationInfo().uid;
            if(uid<10000) throw new SecurityException("Unexpected camera UID");
            if(clientPid>0) {
                String proc=new String(Files.readAllBytes(Paths.get("/proc/"+clientPid+"/cmdline")),StandardCharsets.UTF_8).split("\u0000")[0];
                String identity=new String(Files.readAllBytes(Paths.get("/proc/"+clientPid+"/status")),StandardCharsets.UTF_8);
                if(!proc.equals("com.sec.android.app.camera") || !identity.matches("(?s).*Uid:\\s+"+uid+"\\s+"+uid+"\\s+"+uid+"\\s+"+uid+"\\s.*"))
                    throw new SecurityException("Attribution PID must be the actual installed Samsung Camera process");
            } else {
                android.system.Os.setgid(uid);
                android.system.Os.setuid(uid);
                if(android.os.Process.myUid()!=uid) throw new SecurityException("UID drop failed");
            }
            context=new ContextWrapper(context) {
                @Override public String getOpPackageName() { return getPackageName(); }
                @Override public AttributionSource getAttributionSource() {
                    return new AttributionSource.Builder(clientPid>0?getApplicationInfo().uid:android.os.Process.myUid())
                        .setPid(clientPid>0?clientPid:android.os.Process.myPid()).setPackageName(getPackageName()).build();
                }
            };
        }
        // Avoid the system-context service cache, whose manager remains bound to android.
        CameraManager manager=CameraManager.class.getConstructor(Context.class).newInstance(context);
        emit("begin","route","root_app_process","uid",android.os.Process.myUid(),"context_package",context.getOpPackageName());
        if(Arrays.asList(args).contains("--permit-hidden-client")) {
            // Only this diagnostic manager instance changes; server access checks still apply.
            Field state=CameraManager.class.getDeclaredField("mHiddenCameraPermittedState"); state.setAccessible(true); state.set(manager,Boolean.TRUE);
            emit("local_hidden_filter","override",true,"scope","this CameraManager instance only");
        }
        try { for(String id:new String[]{LOGICAL,MAIN,AUX}) inventory(manager,id); }
        catch(Exception e) { emit("error","stage","inventory","type",e.getClass().getName(),"message",String.valueOf(e.getMessage())); return; }
        if(!Arrays.asList(args).contains("--streams")) return;
        PrivilegedProbe probe=new PrivilegedProbe();
        HandlerThread worker=new HandlerThread("privileged-pair-probe"); worker.start(); probe.handler=new Handler(worker.getLooper());
        probe.handler.post(() -> { probe.handler.postDelayed(() -> probe.stop("timeout"),15000); probe.start(manager); });
        if(!probe.done.await(20,TimeUnit.SECONDS)) { emit("watchdog","reason","no completion in20s"); System.exit(2); }
        // Let asynchronous device-close callbacks drain before ending this isolated process.
        worker.quitSafely(); worker.join(2000);
        System.exit(0);
    }
}
