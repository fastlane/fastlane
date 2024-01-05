package tools.fastlane.localetester;

import android.content.Intent;
import android.os.Bundle;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.text.format.DateFormat;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;

import java.util.Date;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(tools.fastlane.localetester.R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(tools.fastlane.localetester.R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(tools.fastlane.localetester.R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, tools.fastlane.localetester.R.string.hello, Snackbar.LENGTH_LONG).show();
            }
        });

        Button navButton = (Button) findViewById(tools.fastlane.localetester.R.id.nav_button);
        navButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(MainActivity.this, AnotherActivity.class));
            }
        });

        TextView dateText = (TextView) findViewById(tools.fastlane.localetester.R.id.date);
        dateText.setText(DateFormat.getDateFormat(this).format(new Date()));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(tools.fastlane.localetester.R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == tools.fastlane.localetester.R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
