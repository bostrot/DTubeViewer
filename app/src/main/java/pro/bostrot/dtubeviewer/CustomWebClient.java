package pro.bostrot.dtubeviewer;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

public class CustomWebClient extends WebViewClient{
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if(Uri.parse(url).getHost().length() == 0 || Uri.parse(url).getHost().endsWith("emb.d.tube"))
        {
            String historyUrl = "";
            WebBackForwardList mWebBackForwardList = view.copyBackForwardList();
            if (mWebBackForwardList.getItemAtIndex(mWebBackForwardList.getCurrentIndex()-1) != null) {
                historyUrl = mWebBackForwardList.getItemAtIndex(mWebBackForwardList.getCurrentIndex() - 1).getUrl();
            }

            if (!historyUrl.contains("#!/v/") && url.contains("#!/v/")) {
                String tempURL = url;
                tempURL = tempURL.split("#!/v/")[1];
                String account = tempURL.split("/")[0];
                String permalink = tempURL.split("/")[1];


                // Implemented Video Player
                SteemitAPI steemitAPI = new SteemitAPI();
                steemitAPI.getContent(account, permalink, new SteemitAPI.VolleyCallback() {
                    @Override
                    public void onSuccess(JSONObject string) {
                        try {
                            JSONObject video = new JSONObject(string.getJSONObject("result").getString("json_metadata"));
                            String sourceVideo = video.getJSONObject("video").getJSONObject("content").getString("videohash");
                            String compressedVideo = video.getJSONObject("video").getJSONObject("content").getString("video480hash");
                            VideoPlayer vp = new VideoPlayer();
                            Log.d("S/W", sourceVideo + ":" + compressedVideo);
                            vp.video(sourceVideo, compressedVideo);
                        } catch (JSONException e) {}
                    }
                });
            }

            return false;
        }

        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        view.getContext().startActivity(intent);
        return true;
    }
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {

        super.onPageStarted(view, url, favicon);
    }

    @Override
    public void onLoadResource(WebView  view, String  url){
    }

}
