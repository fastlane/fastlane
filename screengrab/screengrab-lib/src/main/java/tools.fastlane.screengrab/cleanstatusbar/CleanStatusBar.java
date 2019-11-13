package tools.fastlane.screengrab.cleanstatusbar;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.InstrumentationRegistry;

public class CleanStatusBar {
    private static final String TAG = "Screengrab";

    private int batteryLevel = 100;
    private boolean batteryPlugged = false;
    private boolean batteryPowerSave = false;
    private IconVisibility airplaneModeVisibility = IconVisibility.HIDE;
    private boolean networkFullyConnected = true;
    private IconVisibility wifiVisibility = IconVisibility.SHOW;
    @Nullable
    private Integer wifiLevel = 4;
    private IconVisibility mobileNetworkVisibility = IconVisibility.SHOW;
    private MobileDataType mobileNetworkDataType = MobileDataType.HIDE;
    @Nullable
    private Integer mobileNetworkLevel = 4;
    private IconVisibility carrierNetworkChangeVisibility = IconVisibility.HIDE;
    private int numberOfSims = 1;
    private IconVisibility noSimVisibility = IconVisibility.HIDE;
    private BarsMode barsMode = BarsMode.TRANSPARENT;
    private VolumeState volumeState = VolumeState.HIDE;
    private BluetoothState bluetoothState = BluetoothState.HIDE;
    private IconVisibility locationVisibility = IconVisibility.HIDE;
    private IconVisibility alarmVisibility = IconVisibility.HIDE;
    private IconVisibility syncVisibility = IconVisibility.HIDE;
    private IconVisibility ttyVisibility = IconVisibility.HIDE;
    private IconVisibility eriVisibility = IconVisibility.HIDE;
    private IconVisibility muteVisibility = IconVisibility.HIDE;
    private IconVisibility speakerphoneVisibility = IconVisibility.HIDE;
    private boolean showNotifications = false;
    private String clock = "1230";

    /**
     * Enables the clean status bar with the default configuration
     */
    public static void enableWithDefaults()
    {
        new CleanStatusBar().enable();
    }

    /**
     * Disables the clean status bar
     */
    public static void disable()
    {
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return;
        sendCommand(InstrumentationRegistry.getTargetContext(), "exit");
    }

    /**
     * Sets the battery level
     * @param batteryLevel the battery level.
     *                     It must be between 0 and 100.
     */
    public CleanStatusBar setBatteryLevel(int batteryLevel) {
        if(batteryLevel < 0 || batteryLevel > 100)
            throw new IllegalArgumentException("Battery level must be between 0 and 100");
        this.batteryLevel = batteryLevel;
        return this;
    }

    /**
     * Sets if the battery is being charged
     * @param batteryPlugged true if the battery is being charged, false otherwise
     */
    public CleanStatusBar setBatteryPlugged(boolean batteryPlugged) {
        this.batteryPlugged = batteryPlugged;
        return this;
    }

    /**
     * Sets if the power save mode is enabled
     * @param batteryPowerSave true if the power save mode is enabled, false otherwise
     */
    public CleanStatusBar setBatteryPowerSave(boolean batteryPowerSave) {
        this.batteryPowerSave = batteryPowerSave;
        return this;
    }

    /**
     * Sets the airplane mode icon visibility
     * @param airplaneModeVisibility the airplane mode {@link IconVisibility}
     */
    public CleanStatusBar setAirplaneModeVisibility(@NonNull IconVisibility airplaneModeVisibility) {
        this.airplaneModeVisibility = airplaneModeVisibility;
        return this;
    }

    /**
     * Sets the MCS state to fully connected
     * @param networkFullyConnected true if the MCS state is fully connected, false otherwise
     */
    public CleanStatusBar setNetworkFullyConnected(boolean networkFullyConnected) {
        this.networkFullyConnected = networkFullyConnected;
        return this;
    }

    /**
     * Sets the wifi icon visibility
     * @param wifiVisibility the wifi {@link IconVisibility}
     */
    public CleanStatusBar setWifiVisibility(@NonNull IconVisibility wifiVisibility) {
        this.wifiVisibility = wifiVisibility;
        return this;
    }

    /**
     * Sets the wifi level
     * @param wifiLevel the wifi level.
     *                  It must be between 0 and 4.
     *                  Set this to null to indicate a disconnected state
     */
    public CleanStatusBar setWifiLevel(@Nullable Integer wifiLevel) {
        if(wifiLevel != null && (wifiLevel < 0 || wifiLevel > 4))
            throw new IllegalArgumentException("Wifi level must be null or between 0 and 4");
        this.wifiLevel = wifiLevel;
        return this;
    }

    /**
     * Sets the mobile network icon visibility
     * @param mobileNetworkVisibility the mobile network {@link IconVisibility}
     */
    public CleanStatusBar setMobileNetworkVisibility(@NonNull IconVisibility mobileNetworkVisibility) {
        this.mobileNetworkVisibility = mobileNetworkVisibility;
        return this;
    }

    /**
     * Sets the mobile network data type
     * @param mobileNetworkDataType the {@link MobileDataType}
     */
    public CleanStatusBar setMobileNetworkDataType(@NonNull MobileDataType mobileNetworkDataType) {
        this.mobileNetworkDataType = mobileNetworkDataType;
        return this;
    }

    /**
     * Sets the mobile network level
     * @param mobileNetworkLevel the mobile network level.
     *                           It must be between 0 and 4.
     *                           Set this to null to indicate a disconnected state
     */
    public CleanStatusBar setMobileNetworkLevel(@Nullable Integer mobileNetworkLevel) {
        if(mobileNetworkLevel != null && (mobileNetworkLevel < 0 || mobileNetworkLevel > 4))
            throw new IllegalArgumentException("Mobile network level must be null or between 0 and 4");
        this.mobileNetworkLevel = mobileNetworkLevel;
        return this;
    }

    /**
     * Sets the carrier network change visibility
     * @param carrierNetworkChangeVisibility the carrier network change {@link IconVisibility}
     */
    public CleanStatusBar setCarrierNetworkChangeVisibility(@NonNull IconVisibility carrierNetworkChangeVisibility) {
        this.carrierNetworkChangeVisibility = carrierNetworkChangeVisibility;
        return this;
    }

    /**
     * Sets the number of sims
     * @param numberOfSims the number of sims.
     *                     This must be between 1 and 8
     */
    public CleanStatusBar setNumberOfSims(int numberOfSims) {
        if(numberOfSims < 1 || numberOfSims > 8)
            throw new IllegalArgumentException("Number of sims must be between 1 and 8");
        this.numberOfSims = numberOfSims;
        return this;
    }

    /**
     * Sets the no sim icon visibility
     * @param noSimVisibility the no sim {@link IconVisibility}
     */
    public CleanStatusBar setNoSimVisibility(@NonNull IconVisibility noSimVisibility) {
        this.noSimVisibility = noSimVisibility;
        return this;
    }

    /**
     * Sets the mode of the SystemUI bars
     * @param barsMode the {@link BarsMode} of the SystemUI
     */
    public CleanStatusBar setBarsMode(@NonNull BarsMode barsMode) {
        this.barsMode = barsMode;
        return this;
    }

    /**
     * Sets the volume state
     * @param volumeState the {@link VolumeState}
     */
    public CleanStatusBar setVolumeState(@NonNull VolumeState volumeState) {
        this.volumeState = volumeState;
        return this;
    }

    /**
     * Sets the bluetooth state
     * @param bluetoothState the {@link BluetoothState}
     */
    public CleanStatusBar setBluetoothState(@NonNull BluetoothState bluetoothState) {
        this.bluetoothState = bluetoothState;
        return this;
    }

    /**
     * Sets the location icon visibility
     * @param locationVisibility the location {@link IconVisibility}
     */
    public CleanStatusBar setLocationVisibility(@NonNull IconVisibility locationVisibility) {
        this.locationVisibility = locationVisibility;
        return this;
    }

    /**
     * Sets the alarm icon visibility
     * @param alarmVisibility the alarm {@link IconVisibility}
     */
    public CleanStatusBar setAlarmVisibility(@NonNull IconVisibility alarmVisibility) {
        this.alarmVisibility = alarmVisibility;
        return this;
    }

    /**
     * Sets the sync icon visibility
     * @param syncVisibility the sync {@link IconVisibility}
     */
    public CleanStatusBar setSyncVisibility(@NonNull IconVisibility syncVisibility) {
        this.syncVisibility = syncVisibility;
        return this;
    }

    /**
     * Sets the TTY icon visibility
     * @param ttyVisibility the TTY {@link IconVisibility}
     */
    public CleanStatusBar setTtyVisibility(@NonNull IconVisibility ttyVisibility) {
        this.ttyVisibility = ttyVisibility;
        return this;
    }

    /**
     * Sets the CDMA ERI icon visibility
     * @param eriVisibility the CDMA ERI {@link IconVisibility}
     */
    public CleanStatusBar setEriVisibility(@NonNull IconVisibility eriVisibility) {
        this.eriVisibility = eriVisibility;
        return this;
    }

    /**
     * Sets the mute icon visibility
     * @param muteVisibility the mute {@link IconVisibility}
     */
    public CleanStatusBar setMuteVisibility(@NonNull IconVisibility muteVisibility) {
        this.muteVisibility = muteVisibility;
        return this;
    }

    /**
     * Sets the speakerphone icon visibility
     * @param speakerphoneVisibility the speakerphone {@link IconVisibility}
     */
    public CleanStatusBar setSpeakerphoneVisibility(@NonNull IconVisibility speakerphoneVisibility) {
        this.speakerphoneVisibility = speakerphoneVisibility;
        return this;
    }

    /**
     * Sets if the notifications are shown
     * @param showNotifications true if the notifications should be shown, false otherwise
     */
    public CleanStatusBar setShowNotifications(boolean showNotifications) {
        this.showNotifications = showNotifications;
        return this;
    }

    /**
     * Sets the time of the clock
     * @param clock the time of the clock.
     *              This must be a string of 4 integers
     */
    public CleanStatusBar setClock(@NonNull String clock) {
        if(!clock.matches("^[0-9]{4}$"))
            throw new IllegalArgumentException("The clock must be a string of 4 integers");
        this.clock = clock;
        return this;
    }

    /**
     * Enables the clean status bar with the current configuration.
     * Changing the configuration after calling this method doesn't effect the status bar.
     * Always call this method after changing the configuration.
     */
    public void enable()
    {
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            Log.w(TAG, "Clean status bar is only supported on Android 6.0 and above");
            return;
        }

        Context context = InstrumentationRegistry.getTargetContext();

        sendCommand(context, "battery", "level", Integer.toString(batteryLevel),
                "plugged", batteryPlugged ? "true" : "false",
                "powersave" , batteryPowerSave ? "true" : "false");

        sendCommand(context, "network", "wifi", wifiVisibility.getValue(),
                "level", wifiLevel == null ? "null" : Integer.toString(wifiLevel));
        sendCommand(context, "network", "nosim", noSimVisibility.getValue());
        sendCommand(context, "network", "airplane", airplaneModeVisibility.getValue());
        // Some network commands conflict...
        if(airplaneModeVisibility == IconVisibility.HIDE) {
            sendCommand(context,"network", "sims", Integer.toString(numberOfSims));
            sendCommand(context,"network", "carriernetworkchange", carrierNetworkChangeVisibility.getValue());
            if(carrierNetworkChangeVisibility == IconVisibility.HIDE) {
                sendCommand(context, "network", "mobile", mobileNetworkVisibility.getValue(),
                        "level", mobileNetworkLevel == null ? "null" : Integer.toString(mobileNetworkLevel),
                        "datatype", mobileNetworkDataType.getValue());
            }
        }
        // For some reason this needs to run after all the other network commands
        sendCommand(context, "network", "fully", networkFullyConnected ? "true" : "false");

        sendCommand(context, "bars", "mode", barsMode.getValue());

        sendCommand(context, "status", "volume", volumeState.getValue());
        sendCommand(context, "status", "bluetooth", bluetoothState.getValue());
        sendCommand(context, "status", "location", locationVisibility.getValue());
        sendCommand(context, "status", "alarm", alarmVisibility.getValue());
        sendCommand(context, "status", "sync", syncVisibility.getValue());
        sendCommand(context, "status", "tty", ttyVisibility.getValue());
        sendCommand(context, "status", "eri", eriVisibility.getValue());
        sendCommand(context, "status", "mute", muteVisibility.getValue());
        sendCommand(context, "status", "speakerphone", speakerphoneVisibility.getValue());

        sendCommand(context, "notifications", "visible", showNotifications ? "true" : "false");

        sendCommand(context, "clock", "hhmm", clock);
    }

    private static void sendCommand(@NonNull Context context, @NonNull String... commands)
    {
        if ((commands.length - 1) % 2 != 0)
            throw new IllegalArgumentException();
        Intent intent = new Intent("com.android.systemui.demo")
                .putExtra("command", commands[0]);
        for (int i = 1; i < commands.length; i += 2) {
            intent.putExtra(commands[i], commands[i + 1]);
        }
        context.sendBroadcast(intent);
    }
}
