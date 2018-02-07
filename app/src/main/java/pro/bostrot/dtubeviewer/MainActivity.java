package pro.bostrot.dtubeviewer;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.PictureInPictureParams;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.SystemClock;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.provider.Settings;
import android.support.constraint.ConstraintLayout;
import android.support.v4.view.GestureDetectorCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;

import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;

public class MainActivity extends AppCompatActivity {

    public static final int REQUEST_SELECT_FILE = 100;
    public ValueCallback<Uri[]> uploadMessage;
    private VideoEnabledWebView wv;
    private static final String TAG = MainActivity.class.getSimpleName();
    boolean videoPlay = false;
    private float scale = 1f;
    private ScaleGestureDetector detector;
    private String[] testEmulatorIDs = {   "2350391e3a011f7a",
                                            "b957e7589d60400e",
                                            "jzt66543zhhfghfg",
                                            "3456235g4s55a4aa", };
    private View nonVideoLayout;
    private ViewGroup videoLayout;
    private VideoEnabledWebChromeClient vewcc;
    public static View loadingView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Analytics - only for releases - Excluding test devices from installation and crash statistics
        String android_id = Settings.Secure.getString(MainActivity.this.getContentResolver(),
                Settings.Secure.ANDROID_ID);
        if (!Arrays.asList(testEmulatorIDs).contains(android_id)) {
            Fabric.with(this, new Crashlytics());
        }

        // Welcome message
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        int currentVersionCode = BuildConfig.VERSION_CODE;
        if (prefs.getInt("LASTVERSION", 0) < currentVersionCode) {
            AlertDialog.Builder builder;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                builder = new AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog_Alert);
            } else {
                builder = new AlertDialog.Builder(this);
            }
            builder.setTitle(getString(R.string.important))
                    .setMessage(getString(R.string.dialog_message))
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            // continue with delete
                        }
                    })
                    .setNeutralButton(getString(R.string.menu_btn), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            Intent i = new Intent(Intent.ACTION_VIEW);
                            i.setData(Uri.parse(getString(R.string.reddit_url)));
                            startActivity(i);
                        }
                    })

                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
            prefs.edit().putInt("LASTVERSION", currentVersionCode).apply();
        }

        // Fullscreen
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // WebView stuff
        wv = findViewById(R.id.htmlLoader);
        wv.setOverScrollMode(View.OVER_SCROLL_NEVER);
        WebSettings webSettings = wv.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setMediaPlaybackRequiresUserGesture(false);
        webSettings.setAllowFileAccessFromFileURLs(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setAllowUniversalAccessFromFileURLs(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setUseWideViewPort(true);
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        CookieManager.getInstance().setAcceptCookie(true);

        // WebChromeClient
        // TODO: Need smoother experience for drawer. Probably open and close it with a swipe through JS
        // TODO: Clicking on it should result in closing
        // TODO: Better loading experience
        // TODO: Notifications from API
        // TODO: Probably changing player iframe to a cast enabled player

        nonVideoLayout = findViewById(R.id.basic); // View with WebView that will be hidden
        videoLayout = findViewById(R.id.videoLayout); // View where video will be shown
        loadingView = getLayoutInflater().inflate(R.layout.loading_view, null);
        vewcc = new VideoEnabledWebChromeClient(nonVideoLayout, videoLayout, loadingView, wv) {
            // File Chooser
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
                // make sure there is no existing message
                if (uploadMessage != null) {
                    uploadMessage.onReceiveValue(null);
                    uploadMessage = null;
                }

                uploadMessage = filePathCallback;

                Intent intent = fileChooserParams.createIntent();
                try {
                    startActivityForResult(intent, REQUEST_SELECT_FILE);
                } catch (ActivityNotFoundException e) {
                    uploadMessage = null;
                    Toast.makeText(MainActivity.this, "Cannot open file chooser", Toast.LENGTH_LONG).show();
                    return false;
                }

                return true;
            }

            // Video Fullscreen Mode
            public void toggledFullscreen(boolean fullscreen)
            {
                Log.d("SESSION21", "inFullscreen");
                // Your code to handle the full-screen change, for example showing and hiding the title bar. Example:
                if (fullscreen)
                {
                    WindowManager.LayoutParams attrs = getWindow().getAttributes();
                    attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags |= WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
                    }
                }
                else
                {
                    WindowManager.LayoutParams attrs = getWindow().getAttributes();
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_FULLSCREEN;
                    attrs.flags &= ~WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;
                    getWindow().setAttributes(attrs);
                    if (android.os.Build.VERSION.SDK_INT >= 14)
                    {
                        //noinspection all
                        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
                    }
                }

            }
        };
        wv.setWebChromeClient(vewcc);
        wv.setWebViewClient(new CustomWebClient());

        if (savedInstanceState == null)
        {
            wv.loadUrl("file:///android_asset/index.html#!/trendingvideos");
        }

        // Started through Intent
        try {
            Intent intent = getIntent();
            String action = intent.getAction();
            Uri data = intent.getData();
            Log.d("IntentData", data.toString());
            String temp = data.toString().replace("https://d.tube/","");
            wv.loadUrl("file:///android_asset/index.html"+temp);
        } catch (Exception e) {
        }

    }

    @Override
    protected void onUserLeaveHint() {
        if (Build.VERSION.SDK_INT > 24 && nonVideoLayout.getVisibility() == View.INVISIBLE) {
            MainActivity.this.enterPictureInPictureMode();
        }
        super.onUserLeaveHint();
    }

    @Override
    public void onPictureInPictureModeChanged (boolean isInPictureInPictureMode, Configuration newConfig) {
        if (isInPictureInPictureMode) {
            // Hide the full-screen UI (controls, etc.) while in picture-in-picture mode.

        } else {
            // Restore the full-screen UI.
            videoLayout.setVisibility(View.VISIBLE);
            loadingView.setVisibility(View.INVISIBLE);
        }
    }

    @Override
    public void onPause() {
        // If called while in PIP mode, do not pause playback
        if (Build.VERSION.SDK_INT > 24) {
            Log.d("PIP", "destroyed everything!");
            if (isInPictureInPictureMode()) {
                // Continue playback
                videoLayout.setVisibility(View.INVISIBLE);
                loadingView.setVisibility(View.VISIBLE);
                wv.loadUrl("javascript:window.location.href = (document.getElementsByTagName('iframe')[0].src);");
            } else {
                // Use existing playback logic for paused Activity behavior.
            }
        }
        super.onPause();
    }

    // Create an image file
    private File createImageFile() throws IOException{
        @SuppressLint("SimpleDateFormat") String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "img_"+timeStamp+"_";
        File storageDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
        return File.createTempFile(imageFileName,".jpg",storageDir);
    }

    @Override
    public void onBackPressed() {
        if(wv.canGoBack()) {
            wv.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState )
    {
        super.onSaveInstanceState(outState);
        wv.saveState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState)
    {
        super.onRestoreInstanceState(savedInstanceState);
        wv.restoreState(savedInstanceState);
    }
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        if (requestCode == REQUEST_SELECT_FILE) {
            if (uploadMessage == null) return;
            uploadMessage.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(resultCode, data));
            uploadMessage = null;
        }
    }
}
