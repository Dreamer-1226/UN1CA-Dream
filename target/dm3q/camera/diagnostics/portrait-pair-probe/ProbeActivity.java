package com.rezoss.portraitpairprobe;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.hardware.camera2.*;
import android.hardware.camera2.params.OutputConfiguration;
import android.hardware.camera2.params.SessionConfiguration;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Range;
import android.util.Size;
import android.widget.*;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;

/** Diagnostic only: two requested physical YUV streams, no frame bytes persisted. */
public final class ProbeActivity extends Activity {
    private static final String LOGICAL = "20", MAIN = "54", AUX = "52";
    private HandlerThread worker;
    private Handler handler;
    private TextView status;
    private CameraDevice device;
    private CameraCaptureSession session;
    private final List<ImageReader> readers = new ArrayList<>();
    private final Map<String, Set<Long>> timestamps = new LinkedHashMap<>();
    private final Set<Long> physicalResultPairs = new HashSet<>();
    private boolean running;
    private boolean attempted;
    private int results;
    private final Runnable timeout = () -> finishProbe("timeout");

    @Override public void onCreate(Bundle saved) {
        super.onCreate(saved);
        worker = new HandlerThread("portrait-pair-probe");
        worker.start();
        handler = new Handler(worker.getLooper());
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(28, 40, 28, 24);
        status = new TextView(this);
        status.setText("Tests logical 20 with physical 54 (10×) + 52 (3×).\n"
            + "Close Samsung Camera first. This opens both cameras for up to 15 seconds. "
            + "Images are discarded; only metadata and calibration hashes are recorded. "
            + "This does not validate depth or calibration geometry.");
        layout.addView(status);
        Button start = new Button(this);
        start.setText("Test 10× + 3× streams");
        start.setOnClickListener(v -> {
            if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.CAMERA}, 1);
            } else handler.post(this::begin);
        });
        layout.addView(start);
        Button stop = new Button(this);
        stop.setText("Stop");
        stop.setOnClickListener(v -> handler.post(() -> finishProbe("user_stop")));
        layout.addView(stop);
        setContentView(layout);
    }

    @Override public void onRequestPermissionsResult(int code, String[] permissions, int[] grants) {
        super.onRequestPermissionsResult(code, permissions, grants);
        if (code == 1 && grants.length > 0 && grants[0] == PackageManager.PERMISSION_GRANTED)
            handler.post(this::begin);
    }

    private void emit(String event, Object... fields) {
        try {
            JSONObject row = new JSONObject();
            row.put("event", event);
            for (int i = 0; i < fields.length; i += 2) row.put(fields[i].toString(), fields[i + 1]);
            try (FileOutputStream out = new FileOutputStream(new File(getFilesDir(), "report.jsonl"), true)) {
                out.write((row + "\n").getBytes(StandardCharsets.UTF_8));
            }
            runOnUiThread(() -> status.setText(row.toString()));
        } catch (Exception error) {
            runOnUiThread(() -> status.setText("Report write failed: " + error));
        }
    }

    private void fail(String stage, Exception error) {
        emit("error", "stage", stage, "type", error.getClass().getName(), "message", String.valueOf(error.getMessage()));
        finishProbe(stage);
    }

    private static String digest(byte[] bytes) throws Exception {
        StringBuilder out = new StringBuilder();
        for (byte b : MessageDigest.getInstance("SHA-256").digest(bytes)) out.append(String.format(Locale.ROOT, "%02x", b & 255));
        return out.toString();
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    private void inventory(CameraManager manager, String id) throws Exception {
        CameraCharacteristics c = manager.getCameraCharacteristics(id);
        emit("camera", "id", id, "physical_ids", new JSONArray(c.getPhysicalCameraIds()),
            "focal_lengths", Arrays.toString(c.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)),
            "active_array", String.valueOf(c.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE)),
            "sync_type", String.valueOf(c.get(CameraCharacteristics.LOGICAL_MULTI_CAMERA_SENSOR_SYNC_TYPE)),
            "timestamp_source", String.valueOf(c.get(CameraCharacteristics.SENSOR_INFO_TIMESTAMP_SOURCE)),
            "intrinsics", Arrays.toString(c.get(CameraCharacteristics.LENS_INTRINSIC_CALIBRATION)),
            "pose_translation", Arrays.toString(c.get(CameraCharacteristics.LENS_POSE_TRANSLATION)),
            "pose_rotation", Arrays.toString(c.get(CameraCharacteristics.LENS_POSE_ROTATION)));
        for (CameraCharacteristics.Key key : c.getKeys()) {
            String name = key.getName();
            if (!name.contains("dualCalibration") && !name.endsWith("rawSensorInfo")) continue;
            Object value = c.get(key);
            if (value instanceof byte[]) {
                byte[] bytes = (byte[]) value;
                emit("calibration_blob", "id", id, "key", name, "bytes", bytes.length, "sha256", digest(bytes));
            } else {
                emit("characteristic", "id", id, "key", name, "value",
                    value instanceof int[] ? Arrays.toString((int[]) value) : String.valueOf(value));
            }
        }
        List<CaptureResult.Key<?>> keys = c.getAvailableCaptureResultKeys();
        if (keys != null) for (CaptureResult.Key<?> key : keys)
            if (key.getName().contains("capturePhysicalId") || key.getName().contains("captureSubPhysicalId"))
                emit("result_key", "id", id, "key", key.getName());
    }

    private Size commonSize(CameraManager manager) throws Exception {
        StreamConfigurationMap a = manager.getCameraCharacteristics(MAIN).get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
        StreamConfigurationMap b = manager.getCameraCharacteristics(AUX).get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
        if (a == null || b == null) throw new IllegalStateException("Missing physical stream map");
        Size[] sa = a.getOutputSizes(ImageFormat.YUV_420_888), sb = b.getOutputSizes(ImageFormat.YUV_420_888);
        if (sa == null || sb == null) throw new IllegalStateException("Missing YUV outputs");
        List<Size> common = new ArrayList<>();
        Set<Size> other = new HashSet<>(Arrays.asList(sb));
        for (Size size : sa)
            if (other.contains(size) && size.getWidth() <= 1920 && size.getHeight() <= 1080
                    && size.getWidth() >= 640 && size.getHeight() >= 480) common.add(size);
        common.sort(Comparator.comparingLong(s -> Math.abs((long)s.getWidth() * s.getHeight() - 640L * 480)));
        if (common.isEmpty()) throw new IllegalStateException("No common bounded YUV output");
        emit("common_sizes", "sizes", new JSONArray(common), "chosen", common.get(0).toString());
        return common.get(0);
    }

    private void begin() {
        if (attempted) return;
        attempted = true;
        running = true;
        timestamps.clear(); physicalResultPairs.clear(); results = 0;
        emit("begin", "logical", LOGICAL, "main", MAIN, "aux", AUX, "time_ms", System.currentTimeMillis());
        handler.postDelayed(timeout, 15000);
        try {
            CameraManager manager = getSystemService(CameraManager.class);
            emit("visible_ids", "ids", new JSONArray(Arrays.asList(manager.getCameraIdList())));
            for (String id : new String[]{LOGICAL, MAIN, AUX}) inventory(manager, id);
            Set<String> members = manager.getCameraCharacteristics(LOGICAL).getPhysicalCameraIds();
            if (!members.contains(MAIN) || !members.contains(AUX))
                throw new IllegalStateException("Requested pair not members of logical camera");
            Size size = commonSize(manager);
            List<OutputConfiguration> outputs = new ArrayList<>();
            for (String id : new String[]{MAIN, AUX}) {
                timestamps.put(id, new HashSet<>());
                ImageReader reader = ImageReader.newInstance(size.getWidth(), size.getHeight(), ImageFormat.YUV_420_888, 3);
                reader.setOnImageAvailableListener(r -> {
                    try (Image image = r.acquireNextImage()) {
                        if (image != null && running) {
                            long ts = image.getTimestamp();
                            // Bounded capture; never retain pixel buffers or write image bytes.
                            if (timestamps.get(id).size() < 240) timestamps.get(id).add(ts);
                            if (timestamps.get(id).size() <= 6) emit("image", "physical_output", id, "timestamp_ns", ts);
                        }
                    } catch (Exception error) { if (running) fail("image", error); }
                }, handler);
                readers.add(reader);
                OutputConfiguration output = new OutputConfiguration(reader.getSurface());
                output.setPhysicalCameraId(id);
                outputs.add(output);
            }
            manager.openCamera(LOGICAL, new CameraDevice.StateCallback() {
                @Override public void onOpened(CameraDevice camera) {
                    if (!running) { camera.close(); return; }
                    device = camera;
                    try {
                        SessionConfiguration config = new SessionConfiguration(SessionConfiguration.SESSION_REGULAR,
                            outputs, command -> handler.post(command), new CameraCaptureSession.StateCallback() {
                                @Override public void onConfigured(CameraCaptureSession configured) {
                                    if (!running) { configured.close(); return; }
                                    session = configured;
                                    try {
                                        CaptureRequest.Builder request = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                                        for (ImageReader reader : readers) request.addTarget(reader.getSurface());
                                        Range<Float> zoom = manager.getCameraCharacteristics(LOGICAL).get(CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE);
                                        if (zoom == null || !zoom.contains(10f)) throw new IllegalStateException("Logical zoom10 unsupported");
                                        request.set(CaptureRequest.CONTROL_ZOOM_RATIO, 10f);
                                        emit("stream_request", "zoom", 10f, "template", "PREVIEW", "format", "YUV_420_888");
                                        session.setRepeatingRequest(request.build(), callback, handler);
                                    } catch (Exception error) { fail("request", error); }
                                }
                                @Override public void onConfigureFailed(CameraCaptureSession failed) {
                                    emit("configure_failed"); finishProbe("configure_failed");
                                }
                            });
                        // The support query may be unimplemented; the actual session result is recorded separately.
                        try { emit("session_support_query", "supported", device.isSessionConfigurationSupported(config)); }
                        catch (Exception unsupported) { emit("session_support_query_error", "type", unsupported.getClass().getName()); }
                        device.createCaptureSession(config);
                    } catch (Exception error) { fail("session", error); }
                }
                @Override public void onDisconnected(CameraDevice camera) { camera.close(); finishProbe("disconnected"); }
                @Override public void onError(CameraDevice camera, int error) { camera.close(); emit("device_error", "code", error); finishProbe("device_error"); }
            }, handler);
        } catch (Exception error) { fail("inventory_or_open", error); }
    }

    private final CameraCaptureSession.CaptureCallback callback = new CameraCaptureSession.CaptureCallback() {
        @Override public void onCaptureCompleted(CameraCaptureSession s, CaptureRequest q, TotalCaptureResult r) {
            if (!running) return;
            results++;
            Map<String, CaptureResult> physical = r.getPhysicalCameraResults();
            if (physical.containsKey(MAIN) && physical.containsKey(AUX)) physicalResultPairs.add(r.getFrameNumber());
            if (results <= 6) {
                emit("result", "frame", r.getFrameNumber(), "timestamp_ns", String.valueOf(r.get(CaptureResult.SENSOR_TIMESTAMP)),
                    "physical_results", new JSONArray(physical.keySet()));
                for (Map.Entry<String, CaptureResult> p : physical.entrySet())
                    emit("physical_result", "id", p.getKey(), "frame", r.getFrameNumber(),
                        "timestamp_ns", String.valueOf(p.getValue().get(CaptureResult.SENSOR_TIMESTAMP)),
                        "focal_length", String.valueOf(p.getValue().get(CaptureResult.LENS_FOCAL_LENGTH)),
                        "crop", String.valueOf(p.getValue().get(CaptureResult.SCALER_CROP_REGION)));
            }
        }
        @Override public void onCaptureFailed(CameraCaptureSession s, CaptureRequest q, CaptureFailure failure) {
            if (!running) return;
            emit("capture_failed", "reason", failure.getReason(), "frame", failure.getFrameNumber());
            finishProbe("capture_failed");
        }
    };

    private void finishProbe(String reason) {
        if (!running) return;
        running = false;
        handler.removeCallbacks(timeout);
        if (session != null) { session.close(); session = null; }
        if (device != null) { device.close(); device = null; }
        for (ImageReader reader : readers) reader.close();
        readers.clear();
        Set<Long> main = timestamps.getOrDefault(MAIN, Collections.emptySet());
        Set<Long> aux = timestamps.getOrDefault(AUX, Collections.emptySet());
        Set<Long> matched = new HashSet<>(main); matched.retainAll(aux);
        emit("summary", "reason", reason, "main_images", main.size(), "aux_images", aux.size(),
            "exact_timestamp_matches", matched.size(), "results", results,
            "frames_with_both_physical_results", physicalResultPairs.size(),
            "calibration_validated", false, "depth_validated", false,
            "scope", "Requested physical YUV outputs; delivery alone does not prove optical identity or Portrait compatibility");
    }

    @Override public void onPause() {
        super.onPause();
        handler.post(() -> finishProbe("activity_paused"));
    }
    @Override public void onDestroy() {
        handler.post(() -> { finishProbe("destroyed"); worker.quitSafely(); });
        super.onDestroy();
    }
}
