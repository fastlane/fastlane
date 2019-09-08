package tools.fastlane.screengrab.cleanstatusbar;

import android.support.annotation.NonNull;

public enum MobileDataType {

    ONEX("1x"),
    THREEG("3g"),
    FOURG("4g"),
    E("e"),
    G("g"),
    H("h"),
    LTE("lte"),
    ROAM("roam"),
    HIDE("hide");

    private final String value;

    MobileDataType(@NonNull String value) {
        this.value = value;
    }

    @NonNull
    public String getValue() {
        return value;
    }
}
