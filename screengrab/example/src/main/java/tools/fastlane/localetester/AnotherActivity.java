package tools.fastlane.localetester;

import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;

public class AnotherActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(tools.fastlane.localetester.R.layout.activity_another);
    }
}
