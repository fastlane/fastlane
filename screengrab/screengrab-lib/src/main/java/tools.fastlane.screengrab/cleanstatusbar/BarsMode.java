package tools.fastlane.screengrab.cleanstatusbar;

import androidx.annotation.NonNull;

public enum BarsMode {

    OPAQUE("opaque"),
    TRANSLUCENT("translucent"),
    SEMI_TRANSPARENT("semi-transparent"),
    TRANSPARENT("transparent"),
    WARNING("warning");

    private final String value;

    BarsMode(@NonNull String value) {
        this.value = value;
    }

    @NonNull
    public String getValue() {
        return value;
    }
}
