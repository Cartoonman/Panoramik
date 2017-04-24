package com.dermandar.panoramal;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.DownloadManager;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.dermandar.dmd_lib.CallbackInterfaceViewer;
import com.dermandar.dmd_lib.DMD_Viewer;

public class ViewerActivity extends Activity {
    private RelativeLayout mRelativeLayoutRoot;

    private DMD_Viewer mDMDViewer;
    private View mViewViewer;

    public static TextView tv;
    public Timer tr;
    public static String rp;

    private Display mDisplay;
    private DisplayMetrics mDisplayMetrics;
    private CallbackInterfaceViewer mCallbackInterfaceViewer = new CallbackInterfaceViewer() {
        @Override
        public void onSingleTapConfirmed() {
            System.out.println("testttttttttttttttttttttttting");
        }

        @Override
        public void onFinishLoadingPanorama() {
        }

        @Override
        public void onFinishGeneratingEqui() {
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //getting screen resolution
        mDisplay = getWindowManager().getDefaultDisplay();
        mDisplayMetrics = new DisplayMetrics();
        mDisplay.getMetrics(mDisplayMetrics);

        mRelativeLayoutRoot = new RelativeLayout(this);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);
        mRelativeLayoutRoot.setLayoutParams(layoutParams);

        mDMDViewer = new DMD_Viewer();
        mViewViewer = null;
        mViewViewer = mDMDViewer.initViewer(this, mCallbackInterfaceViewer, getWindowManager().getDefaultDisplay().getRotation());
        mRelativeLayoutRoot.addView(mViewViewer);

        //////////////////////
        ViewerActivity.tv = new TextView(this);
        ViewerActivity.tv.setTextSize(15f);
        ViewerActivity.tv.setText(ShooterActivity.testString);
        mRelativeLayoutRoot.addView(ViewerActivity.tv);
        /////////////////////
        setContentView(mRelativeLayoutRoot);

        tr = new Timer();
        final RequestQueue queue = Volley.newRequestQueue(this);
        tr.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                String url ="http://panoramik.herokuapp.com/status?job_id="+rp;

                // Request a string response from the provided URL.
                StringRequest stringRequest = new StringRequest(url,
                        new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {
                                // Display the first 500 characters of the response string.
                                tv.setText(response);
                                // System.out.println("Response is: "+ response.substring(0,10));
                            }
                        }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        System.out.println("donnnnnnnnnnnnnnnnt wooooooooooooorrrrrrrkkkkkkkkk");
                    }
                });
// Add the request to the RequestQueue.
                queue.add(stringRequest);
            }
        }, 10000, 5000);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mDMDViewer.stopViewer();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mDMDViewer.startViewer();
    }
}
