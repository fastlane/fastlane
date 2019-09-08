package tools.fastlane.screengrab.cleanstatusbar;

import android.support.annotation.NonNull;

public enum BluetoothState {

    CONNECTED("connected"),
    DISCONNECTED("disconnected"),
    HIDE("hide");

    private final String value;

    BluetoothState(@NonNull String value) {
        this.value = value;
    }

    @NonNull
    public String getValue() {
        return value;
    }
}
