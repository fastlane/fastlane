package tools.fastlane.screengrab.cleanstatusbar;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

final class DemoModeCallbackBroadcastReceiver extends BroadcastReceiver {
    private final Runnable mCallback;

    DemoModeCallbackBroadcastReceiver(Runnable callback) {
        mCallback = callback;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        mCallback.run();
    }
}
