package com.dermandar.panoramal;

import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.DownloadManager;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class ViewerActivity extends Activity {

    public static JSONArray hello;
    TextToSpeech tts1;

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

        tts1 = new TextToSpeech(getApplicationContext(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if(status != TextToSpeech.ERROR) {
                    tts1.setLanguage(Locale.US);
                    tts1.setSpeechRate(1/2);
                }
            }
        });


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
                                //please poop
                                try{
                                    tts1.speak("Objects", TextToSpeech.QUEUE_FLUSH, null);
                                    System.out.println("fshfdhfsfhsjfhdsufhfhdskjfhsfksh11111111111111111");
                                    JSONObject json = new JSONObject(response);
                                    System.out.println("fshfdhfsfhsjfhdsufhfhdskjfhsfksh22222222222222222");
                                    ViewerActivity.hello = (JSONArray)json.get("final_result");
                                    System.out.println("fshfdhfsfhsjfhdsufhfhdskjfhsfksh33333333333333333");
                                    System.out.println("000000000000000000000000000000000000000000000000000000000000000000");
                                    System.out.println(hello);
                                    System.out.println(hello.length());
                                    for( int x = 0; x < hello.length(); x++){
                                        //System.out.println(hello.get(x)); this prints out everything in the json
                                        JSONArray image = (JSONArray)hello.get(x);
                                        JSONObject dict = (JSONObject)image.get(0);
                                        JSONArray cloudsight = (JSONArray)dict.get("cloudsight");
                                        String status = (String)cloudsight.get(0);
                                        //System.out.println(status);
                                        if(status.equals("completed")){
                                            String result = (String)cloudsight.get(1);
                                            System.out.println(result);
                                            tts1.speak(result, TextToSpeech.QUEUE_ADD, null);
                                        }
                                        //tts1.speak("Objects detected ", TextToSpeech.QUEUE_FLUSH, null);

                                    }



                                    tr.cancel();

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
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
