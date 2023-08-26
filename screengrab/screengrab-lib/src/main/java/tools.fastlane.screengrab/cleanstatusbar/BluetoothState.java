package tools.fastlane.screengrab.cleanstatusbar;

import androidx.annotation.NonNull;

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
