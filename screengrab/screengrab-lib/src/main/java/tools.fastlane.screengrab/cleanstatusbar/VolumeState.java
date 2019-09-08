package tools.fastlane.screengrab.cleanstatusbar;

import android.support.annotation.NonNull;

public enum VolumeState {

    SILENT("silent"),
    VIBRATE("vibrate"),
    HIDE("hide");

    private final String value;

    VolumeState(@NonNull String value) {
        this.value = value;
    }

    @NonNull
    public String getValue() {
        return value;
    }
}
