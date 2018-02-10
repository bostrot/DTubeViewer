package pro.bostrot.dtubeviewer;

import android.app.MediaRouteButton;
import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.SimpleExoPlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import java.util.List;


import static pro.bostrot.dtubeviewer.MainActivity.activity;

public class VideoPlayer {
    public static boolean isInFullscreen = false;
    final SimpleExoPlayerView simpleExoPlayerView = activity.findViewById(R.id.videoPlayer);
    final ImageButton but = activity.findViewById(R.id.exo_fullscreen_button);
    final WebView web = activity.findViewById(R.id.htmlLoader);
    public static SimpleExoPlayer player;
    public static String lastUrl;

    public void video(final String source, final String compressed) {
        final String url = "https://gateway.ipfs.io/ipfs/" + source;
                lastUrl = url;
        Uri videoUri =  Uri.parse( url );
        Log.d("S/W2", url + ":" + videoUri.toString());
        simpleExoPlayerView.setVisibility(View.VISIBLE);

        but.setOnClickListener(new View.OnClickListener() {
            int click = 0;
            @Override
            public void onClick(View view) {
                if (click == 0) {
                    enterFullscreen();
                    click = 1;
                } else if (click == 1) {
                    exitFullscreen();
                    click = 0;
                }
            }
        });
        //activity.findViewById(R.id.htmlLoader).setVisibility(View.INVISIBLE);

        // 1. Create a default TrackSelector
        Handler mainHandler = new Handler();
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);

        // 2. Create the player
        player = ExoPlayerFactory.newSimpleInstance(activity, trackSelector);

        // Bind the player to the view.
        simpleExoPlayerView.setPlayer(player);

        // Measures bandwidth during playback. Can be null if not required.
        DefaultBandwidthMeter defaultBandwidthMeter = new DefaultBandwidthMeter();
        // Produces DataSource instances through which media data is loaded.
        DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(activity,
                Util.getUserAgent(activity, "DTube"), defaultBandwidthMeter);
        // This is the MediaSource representing the media to be played.
        MediaSource videoSource = new ExtractorMediaSource.Factory(dataSourceFactory)
                .createMediaSource(videoUri);
        // Prepare the player with the source.
        player.prepare(videoSource);
        player.setPlayWhenReady(true);
    }

    public void exitFullscreen() {
        isInFullscreen = false;
        activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        final float scale = activity.getResources().getDisplayMetrics().density;
        int height = (int) (245 * scale + 0.5f);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                height
        );
        simpleExoPlayerView.setLayoutParams(params);
        web.setVisibility(View.VISIBLE);
    }

    public void enterFullscreen() {
        isInFullscreen = true;

        View decorView = activity.getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN;
        decorView.setSystemUiVisibility(uiOptions);

        activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
        );
        simpleExoPlayerView.setLayoutParams(params);
        web.setVisibility(View.GONE);
    }


}
