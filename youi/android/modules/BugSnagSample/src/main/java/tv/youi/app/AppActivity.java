package tv.youi.app;

import android.os.Bundle;

import com.bugsnag.android.Bugsnag;

import tv.youi.youiengine.CYIActivity;

public class AppActivity extends CYIActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Start Bugsnag
        Bugsnag.start(this);

        // Test Bugsnag
        Bugsnag.notify(new RuntimeException("Test error"));
    }
}
