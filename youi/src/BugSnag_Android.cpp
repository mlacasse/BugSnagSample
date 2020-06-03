#if defined(YI_ANDROID)

#include <jni.h>
#include <bugsnag.h>

#include <utility/YiString.h>

extern JavaVM *cachedJVM;
extern jobject cachedActivity;

extern "C"
{
static void __attribute__((used)) somefakefunc(void) {}

int crash_write_read_only() {
    // Write to a read-only page
    volatile char *ptr = (char *)somefakefunc;
    *ptr = 0;

    return 5;
}

bool my_on_error_b(void *event) {
    bugsnag_event_set_user(event, const_cast<char *>("999999"), const_cast<char *>("John Doe"), const_cast<char *>("john_doe@stranger.com"));
    bugsnag_event_add_metadata_string(event, const_cast<char *>("Native"), const_cast<char *>("field"), const_cast<char *>("value"));
    bugsnag_event_add_metadata_bool(event, const_cast<char *>("Native"), const_cast<char *>("field"), true);
    return true;
}

JNIEXPORT void JNICALL Java_tv_youi_app_AppActivity_performNativeBugsnagSetup(JNIEnv *env, jobject instance) {
    bugsnag_add_on_error(&my_on_error_b);
}

JNIEXPORT void JNICALL Java_tv_youi_app_AppActivity_doCrash(JNIEnv *env, jobject instance) {
    crash_write_read_only();
}

JNIEXPORT void JNICALL Java_tv_youi_app_AppActivity_notifyFromCXX(JNIEnv *env, jobject instance) {
    // Set the current user
    bugsnag_set_user_env(env, const_cast<char *>("124323"), const_cast<char *>("joe mills"), const_cast<char *>("j@ex.co"));
    // Leave a breadcrumb
    bugsnag_leave_breadcrumb_env(env, const_cast<char *>("Critical failure"), BSG_CRUMB_LOG);
    // Send an error report
    bugsnag_notify_env(env, const_cast<char *>("Oh no"), const_cast<char *>("The mill!"), BSG_SEVERITY_INFO);
}
}

#endif
