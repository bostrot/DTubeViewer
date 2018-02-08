package pro.bostrot.dtubeviewer;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.view.WindowManager;
import android.webkit.WebBackForwardList;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by erict on 08.02.2018.
 */

public class CacheWebView extends WebViewClient{
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if(Uri.parse(url).getHost().length() == 0 || Uri.parse(url).getHost().endsWith("emb.d.tube"))
        {
            return false;
        }

        // Hide status bar in fullscreen
        MainActivity activity = new MainActivity();
        if (Uri.parse(url).getHost().contains("embed.html#!/v/")) {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        } else {
            activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        view.getContext().startActivity(intent);
        return true;
    }
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {


        super.onPageStarted(view, url, favicon);
    }
}
