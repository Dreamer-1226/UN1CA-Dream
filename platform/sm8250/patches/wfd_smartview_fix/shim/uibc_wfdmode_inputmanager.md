# uibc_java.jar WFDMode input injection fix

One UI 9 (AOSP 14+) removed the static `InputManager.getInstance()`; the
injector lives on `InputManagerGlobal` now. The One UI 8.5 WFDMode in
uibc_java.jar still called `InputManager.getInstance().injectInputEvent()`,
so every UIBC touch from the sink threw
`NoSuchMethodError: InputManager.getInstance()` on the android.wfd thread and
killed system_server (soft reboot on touch).

Fix: in com/samsung/android/wfd/WFDMode.smali, the 3 injection call sites now
use InputManagerGlobal instead:
  Landroid/hardware/input/InputManager;->getInstance()Landroid/hardware/input/InputManager;
    -> Landroid/hardware/input/InputManagerGlobal;->getInstance()Landroid/hardware/input/InputManagerGlobal;
  Landroid/hardware/input/InputManager;->injectInputEvent(Landroid/view/InputEvent;I)Z
    -> Landroid/hardware/input/InputManagerGlobal;->injectInputEvent(Landroid/view/InputEvent;I)Z

DeXMode in the same jar has the same pattern but also calls Samsung-only
getGlobalMetaState(I)/forceFadeIcon(I), whose presence on InputManagerGlobal
is unverified, so it is intentionally left untouched (DeX-over-WFD touch would
still need its own fix).
