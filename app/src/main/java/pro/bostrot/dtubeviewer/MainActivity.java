package pro.bostrot.dtubeviewer;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.app.MediaRouteButton;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import com.crashlytics.android.Crashlytics;
import com.crashlytics.android.answers.Answers;
import com.crashlytics.android.answers.CustomEvent;
import com.google.android.gms.cast.MediaInfo;
import com.google.android.gms.cast.MediaMetadata;
import com.google.android.gms.cast.framework.CastButtonFactory;
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.CastState;
import com.google.android.gms.cast.framework.CastStateListener;
import com.google.android.gms.cast.framework.Session;
import com.google.android.gms.cast.framework.SessionManager;
import com.google.android.gms.cast.framework.SessionManagerListener;
import com.google.android.gms.cast.framework.media.RemoteMediaClient;
import com.google.android.gms.common.images.WebImage;
import com.google.firebase.analytics.FirebaseAnalytics;

import org.json.JSONException;
import org.json.JSONObject;

import io.fabric.sdk.android.Fabric;

import static pro.bostrot.dtubeviewer.InstallReferrerReceiver.referrer;
import static pro.bostrot.dtubeviewer.VideoPlayer.isInFullscreen;
import static pro.bostrot.dtubeviewer.VideoPlayer.lastUrl;
import static pro.bostrot.dtubeviewer.VideoPlayer.player;

public class MainActivity extends AppCompatActivity {

    public static final int REQUEST_SELECT_FILE = 100;
    public ValueCallback<Uri[]> uploadMessage;
    public static VideoEnabledWebView wv;
    private static final String TAG = MainActivity.class.getSimpleName();
    private String[] testEmulatorIDs = {   "2350391e3a011f7a",
                                            "b957e7589d60400e",
                                            "jzt66543zhhfghfg",
                                            "3456235g4s55a4aa", };
    private View nonVideoLayout;
    private ViewGroup videoLayout;
    private VideoEnabledWebChromeClient vewcc;
    public static View loadingView;
    public static Activity activity;
    public static int timePlayed = 0;

    long position;
    SteemitAPI steemitAPI;
    VideoPlayer videoPlayer;

    MediaRouteButton mMediaRouteButton;
    private CastSession mCastSession;
    private SessionManager mSessionManager;
    private final SessionManagerListener mSessionManagerListener =
            new SessionManagerListenerImpl();
    MediaMetadata movieMetadata;
    MediaInfo mediaInfo;
    CastContext mCastContext;

    private FirebaseAnalytics mFirebaseAnalytics;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        activity = MainActivity.this;


        // Keep alive
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        videoPlayer = new VideoPlayer();

        // Analytics - only for releases - Excluding test devices from installation and crash statistics
        String android_id = Settings.Secure.getString(MainActivity.this.getContentResolver(),
                Settings.Secure.ANDROID_ID);
        if (!Arrays.asList(testEmulatorIDs).contains(android_id)) {
            Fabric.with(this, new Crashlytics());// Obtain the FirebaseAnalytics instance.
            mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
            if (referrer != null && !referrer.equals("empty")) {
                Answers.getInstance().logCustom(new CustomEvent("Referrer")
                        .putCustomAttribute("ID", referrer));
            }
        }

        // Welcome message
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        int currentVersionCode = BuildConfig.VERSION_CODE;
        if (prefs.getInt("LASTVERSION", 0) < currentVersionCode) {
            AlertDialog.Builder builder;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                builder = new AlertDialog.Builder(this, R.style.AppCompatAlertDialogStyle);
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

        // Support message
        if (prefs.getInt("DISPLAYED", 0) > 2) {
            AlertDialog.Builder builder;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                builder = new AlertDialog.Builder(this, R.style.AppCompatAlertDialogStyle);
            } else {
                builder = new AlertDialog.Builder(this);
            }
            builder.setTitle(getString(R.string.support_title))
                    .setMessage(getString(R.string.support_text))
                    .setNeutralButton(android.R.string.no, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                        }
                    })
                    .setNegativeButton(getString(R.string.Bitcoin_button), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            Intent i = new Intent(Intent.ACTION_VIEW);
                            i.setData(Uri.parse(getString(R.string.Bitcoin_url)));
                            startActivity(i);
                        }
                    })
                    .setPositiveButton(getString(R.string.PayPal_button), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            Intent i = new Intent(Intent.ACTION_VIEW);
                            i.setData(Uri.parse(getString(R.string.PayPal_url)));
                            startActivity(i);
                        }
                    })
                    .show();
            prefs.edit().putInt("DISPLAYED", 0).apply();
        }
        prefs.edit().putInt("DISPLAYED", (prefs.getInt("DISPLAYED", 0) + 1)).apply();

        // Fullscreen
        //getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        this.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // WebView Settings - JS, Media, etc..
        wv = findViewById(R.id.htmlLoader);
        wv.setOverScrollMode(View.OVER_SCROLL_NEVER);
        webViewSettings(wv.getSettings());

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
        };
        wv.setWebChromeClient(vewcc);
        wv.setWebViewClient(new CustomWebClient());

        if (savedInstanceState != null) {
            wv.restoreState(savedInstanceState);
        } else {
            wv.loadUrl("file:///android_asset/index.html#!");
            wv.loadUrl("javascript:document.getElementsByClassName('.blacklogo')[0].click()");
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

        // Casting
        mCastContext = CastContext.getSharedInstance(this);
        mMediaRouteButton = (MediaRouteButton) findViewById(R.id.media_route_button);
        CastButtonFactory.setUpMediaRouteButton(this, mMediaRouteButton);

        mSessionManager = mCastContext.getSessionManager();
    }

    private void loadRemoteMedia(int position, boolean autoPlay) {
        Log.d("CAST SESSION 2", lastUrl);
        movieMetadata = new MediaMetadata(MediaMetadata.MEDIA_TYPE_MOVIE);

        movieMetadata.putString(MediaMetadata.KEY_TITLE, "DTube");
        movieMetadata.putString(MediaMetadata.KEY_SUBTITLE, "Bostrot is streaming content...");
        movieMetadata.addImage(new WebImage(Uri.parse("https://steemit-production-imageproxy-upload.s3.amazonaws.com/DQmeddeVdpUn2d6VKNTNt9EGDYRucxKPAZRKodA88k2YtB9")));
        movieMetadata.addImage(new WebImage(Uri.parse("https://steemit-production-imageproxy-upload.s3.amazonaws.com/DQmeddeVdpUn2d6VKNTNt9EGDYRucxKPAZRKodA88k2YtB9")));

        mediaInfo = new MediaInfo.Builder(lastUrl)
                .setStreamType(MediaInfo.STREAM_TYPE_LIVE)
                .setContentType("videos/mp4")
                .setMetadata(movieMetadata)
                .build();

        if (mCastSession == null) {
            Log.d("mCastSession", "null");
            return;
        }
        final RemoteMediaClient remoteMediaClient = mCastSession.getRemoteMediaClient();
        if (remoteMediaClient == null) {
            Log.d("remoteMediaClient", "null");
            return;
        }
        remoteMediaClient.addListener(new RemoteMediaClient.Listener() {

            @Override
            public void onStatusUpdated() {
                Intent intent = new Intent(MainActivity.this, ExpandedControlsActivity.class);
                startActivity(intent);
                remoteMediaClient.removeListener(this);
            }

            @Override
            public void onMetadataUpdated() {
            }

            @Override
            public void onQueueStatusUpdated() {
            }

            @Override
            public void onPreloadStatusUpdated() {
            }

            @Override
            public void onAdBreakStatusUpdated() {
            }
            @Override
            public void onSendingRemoteMediaRequest() {
            }
        });
        remoteMediaClient.load(mediaInfo, autoPlay, position);
    }


    @Override public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);
        getMenuInflater().inflate(R.menu.browse, menu);
        CastButtonFactory.setUpMediaRouteButton(getApplicationContext(),
                menu,
                R.id.media_route_menu_item);
        return true;
    }

    private class SessionManagerListenerImpl implements SessionManagerListener<CastSession> {
        @Override
        public void onSessionStarted(CastSession session, String sessionId) {
            mCastSession = session;
            Log.d("CAST SESSION", "started");
            player.release();
            loadRemoteMedia(0, true);
            invalidateOptionsMenu();
        }
        @Override
        public void onSessionResumed(CastSession session, boolean wasSuspended) {
            mCastSession = session;
            invalidateOptionsMenu();
        }
        @Override
        public void onSessionEnded(CastSession session, int error) {
            Log.d("Session", "Ended");
            if (session == mCastSession) {
                mCastSession = null;
            }
        }
        @Override
        public void onSessionEnding(CastSession session) {
            Log.d("Session", "Ended2");
        }
        @Override
        public void onSessionResumeFailed(CastSession session, int error) {
            Log.d("Session", "Ended3");
        }
        @Override
        public void onSessionStartFailed(CastSession session, int error) {
            Log.d("Session", "Ended4");
        }
        @Override
        public void onSessionResuming(CastSession session, String sessionId) {
            Log.d("Session", "Ended5");
        }
        @Override
        public void onSessionStarting(CastSession session) {
            Log.d("Session", "Ended6");
        }
        @Override
        public void onSessionSuspended(CastSession session, int error) {
            Log.d("Session", "Ended7");
        }
    }


    public void webViewSettings(WebSettings webSettings) {
        webSettings.setJavaScriptEnabled(true);
        webSettings.setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        webSettings.setMediaPlaybackRequiresUserGesture(true);
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
    }

    @Override
    protected void onUserLeaveHint() {
        if (Build.VERSION.SDK_INT >= 26 && isInFullscreen) {

            MainActivity.this.enterPictureInPictureMode();
        }
        super.onUserLeaveHint();
    }

    @Override
    public void onPictureInPictureModeChanged (boolean isInPictureInPictureMode, Configuration newConfig) {
        if (isInPictureInPictureMode) {
            // Hide the full-screen UI (controls, etc.) while in picture-in-picture mode.
            // Continue playback
        } else {
            // Restore the full-screen UI.
        }
    }

    @Override
    public void onPause() {

        if (Build.VERSION.SDK_INT >= 26) {
            Log.d("PIP", "here!");
            if (isInPictureInPictureMode()) {
                // Continue playback
                videoPlayer.enterFullscreen();
            } else {
                // Use existing playback logic for paused Activity behavior.
                videoPlayer.exitFullscreen();
            }
        }
        super.onPause();
        mSessionManager.removeSessionManagerListener(mSessionManagerListener);
        mCastSession = null;
    }


    @Override
    protected void onResume() {
        mCastSession = mSessionManager.getCurrentCastSession();
        mSessionManager.addSessionManagerListener(mSessionManagerListener);
        super.onResume();
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
        if (wv.canGoBack()) {
            if (isInFullscreen) {
                videoPlayer.exitFullscreen();
            } else {
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                findViewById(R.id.videoPlayer).setVisibility(View.GONE);
                if (player != null && player.getCurrentTimeline() != null) {
                    player.release();
                }
                wv.goBack();
            }
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

    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        if (requestCode == REQUEST_SELECT_FILE) {
            if (uploadMessage == null) return;
            uploadMessage.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(resultCode, data));
            uploadMessage = null;
        }
    }
}
