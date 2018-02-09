package pro.bostrot.dtubeviewer;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.JsonRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import static com.android.volley.VolleyLog.TAG;
import static pro.bostrot.dtubeviewer.MainActivity.activity;

/**
 * Created by erict on 09.02.2018.
 */

public class SteemitAPI {

    public void getContent(final String accountname, final String permalink, final VolleyCallback callback) {
        try {
            JSONArray jsonArray = new JSONArray();
            jsonArray.put(accountname);
            jsonArray.put(permalink);

            Log.d("jsonObject", jsonArray.toString());

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("jsonrpc", "2.0");
            jsonObject.put("method", "get_content");
            jsonObject.put("params", (Object)jsonArray);
            jsonObject.put("id", "1");

            RequestQueue requestQueue = Volley.newRequestQueue(activity);
            String url = "https://api.steemit.com";
            JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.POST, url, jsonObject, new Response.Listener<JSONObject>() {
                @Override
                public void onResponse(JSONObject response) {
                    callback.onSuccess(response);
                }
            }, new Response.ErrorListener() { //Create an error listener to handle errors appropriately.
                @Override
                public void onErrorResponse(VolleyError error) {
                    //This code is executed if there is an error.
                }
            });
            requestQueue.add(jsonObjectRequest);
        } catch (JSONException e) {}
    }

    public interface VolleyCallback{
        void onSuccess(JSONObject string);
    }

}
