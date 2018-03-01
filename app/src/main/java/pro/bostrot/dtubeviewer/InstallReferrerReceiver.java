package pro.bostrot.dtubeviewer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class InstallReferrerReceiver extends BroadcastReceiver {
    public static String referrer = "empty";
    @Override
    public void onReceive(Context context, Intent intent) {
        //Use the referrer
        referrer = intent.getStringExtra("referrer");
        Log.d("Referrer", "set");
    }
}