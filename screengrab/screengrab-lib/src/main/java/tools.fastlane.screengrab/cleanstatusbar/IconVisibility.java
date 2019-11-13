package tools.fastlane.screengrab.cleanstatusbar;

import androidx.annotation.NonNull;

public enum IconVisibility {

    SHOW("show"),
    HIDE("hide");

    private final String value;

    IconVisibility(@NonNull String value) {
        this.value = value;
    }

    @NonNull
    public String getValue() {
        return value;
    }
}
