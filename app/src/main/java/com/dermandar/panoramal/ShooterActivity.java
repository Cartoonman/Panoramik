package com.dermandar.panoramal;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.media.ExifInterface;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

//starting here//
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.provider.ContactsContract.PhoneLookup;
import android.speech.tts.TextToSpeech;
import android.telephony.SmsMessage;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.TextView;
import android.widget.ToggleButton;
//ending here//

import android.speech.tts.TextToSpeech;
import android.view.View.OnClickListener;

import com.dermandar.dmd_lib.CallbackInterfaceShooter;
import com.dermandar.dmd_lib.DMD_Capture;
import com.dermandar.dmd_lib.DMD_Capture.FinishShootingEnum;
import com.kosalgeek.android.photoutil.ImageBase64;
import com.kosalgeek.android.photoutil.ImageLoader;
import com.kosalgeek.android.photoutil.MainActivity;
import com.kosalgeek.genasync12.AsyncResponse;
import com.kosalgeek.genasync12.EachExceptionsHandler;
import com.kosalgeek.genasync12.PostResponseAsyncTask;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;


public class ShooterActivity extends Activity
{

    /////
    public static String testString = "Processing...";
    /////
    TextToSpeech tts;
    private Handler mHandler;

    private RelativeLayout mRelativeLayoutRoot;
    private ViewGroup mViewGroupCamera;
    private DMD_Capture mDMDCapture;

    private Display mDisplay;
    private DisplayMetrics mDisplayMetrics;

    private ImageViewBordered mImageViewCameraCaptureEffect;
    private Bitmap mBitmapCameraCaptureEffect;
    private AlphaAnimation mAlphaAnimationCameraCaptureEffect;
    private AnimationSet mAnimationSetCameraCaptureEffect;
    private View mViewPreviewCaptureEffect;

//added more shizzles


//here end shizzles


    private TextView mResultText;
    private TextView mTextViewInstruction;

    private LinearLayout linearLayout;

    private SimpleDateFormat mSimpleDateFormat;

    private String mPanoramaName, mEquiPath;
    private boolean mIsCapturing, mIsStitching;
    private int mNumberTakenImages;

    private int mCurrentInstructionMessageID = -1;
    private int lAngle = 0;
    private View.OnClickListener mCameraOnClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (mIsCapturing) {
                //clear the flag to prevent the screen of being on
                getWindow().clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

                if (mDMDCapture.finishShooting()) {
                    mIsStitching = true;
                    mTextViewInstruction.setVisibility(View.INVISIBLE);
                }
                mIsCapturing = false;
                //tts.speak("Tap to start", TextToSpeech.QUEUE_FLUSH, null);
                setInstructionMessage(R.string.instruction_tap_start);
            } else {
                mNumberTakenImages = 0;
                mPanoramaName = mSimpleDateFormat.format(new Date());

                if (mDMDCapture.startShooting()) {
                    tts.speak("Focusing", TextToSpeech.QUEUE_FLUSH, null);
                    setInstructionMessage(R.string.instruction_focusing);
                    mIsCapturing = true;
                    //set flag to keep the screen on
                    getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                }
            }
        }
    };
    private CallbackInterfaceShooter mCallbackInterface = new CallbackInterfaceShooter() {

        @Override
        public void takingPhoto() {
            //tts.speak("Taking Photo", TextToSpeech.QUEUE_FLUSH, null);
            if (mImageViewCameraCaptureEffect.getParent() != null) {
                mViewGroupCamera.removeView(mImageViewCameraCaptureEffect);
                mImageViewCameraCaptureEffect.setImageDrawable(null);
            }
            if (mViewPreviewCaptureEffect.getParent() != null) {
                mViewGroupCamera.removeView(mViewPreviewCaptureEffect);
            }

            mImageViewCameraCaptureEffect.setImageBitmap(mBitmapCameraCaptureEffect); // image?
            mViewGroupCamera.addView(mImageViewCameraCaptureEffect);
            mViewGroupCamera.addView(mViewPreviewCaptureEffect);
            mViewPreviewCaptureEffect.startAnimation(mAlphaAnimationCameraCaptureEffect);
        }

        @Override
        public void stitchingCompleted(HashMap<String, Object> info) {
            File equiFolder = new File(Environment.getExternalStorageDirectory() + "/" + Globals.EQUI_FOLDER_NAME + "/");
            if (equiFolder.exists() == false) {
                equiFolder.mkdir();
            }
            mEquiPath = equiFolder.getPath() + "/" + mPanoramaName + ".jpg";
            mDMDCapture.genEquiAt(mEquiPath, 800, 0, 0);

            //##########################################

            int obj = (Integer) info.get(FinishShootingEnum.fovx.name());
            Log.wtf("@__@", "++++++   stitchingCompleted:" + obj);
            lAngle = obj;
            //##########################################
            ShooterActivity.testString = "Processing...";
        }

        @Override
        public void shootingCompleted(boolean finished) {
            //clear the flag to prevent the screen of being on
            tts.speak("Finish taking panorama", TextToSpeech.QUEUE_FLUSH, null);
            getWindow().clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            if (finished) {
                mTextViewInstruction.setVisibility(View.INVISIBLE);
                mIsStitching = true;
            }
            mIsCapturing = false;
        }

        @Override
        public void preparingToShoot() {
        }

        @Override
        public void photoTaken() {
            if (mNumberTakenImages == 0) {
                setInstructionMessage(R.string.instruction_first_shot);
                tts.speak("Rotate left or right or tap to restart", TextToSpeech.QUEUE_FLUSH, null);
            } else {
                setInstructionMessage(R.string.instruction_finish_shot);
                tts.speak("Tap to finish when ready or continue rotating", TextToSpeech.QUEUE_FLUSH, null);
            }
            mNumberTakenImages++;
            mImageViewCameraCaptureEffect.startAnimation(mAnimationSetCameraCaptureEffect);
        }

        @Override
        public void deviceVerticalityChanged(int isVertical) {
            if (!mIsCapturing) {
                if (isVertical == 1) {
                    tts.speak("Tap to start", TextToSpeech.QUEUE_FLUSH, null);
                    setInstructionMessage(R.string.instruction_tap_start);
                } else {
                    tts.speak("Hold your device vertically", TextToSpeech.QUEUE_FLUSH, null);
                    setInstructionMessage(R.string.instruction_hold_vertically);
                }
            }
        }

        @Override
        public void compassEvent(HashMap<String, Object> info) {
            if (info != null) {
                Object obj = info.get(DMD_Capture.CompassActionEnum.kDMDCompassInterference.name());
                if (obj != null && obj instanceof Boolean && obj.equals(Boolean.TRUE)) {
                    toastMessage(getString(R.string.compass_interference_msg));
                }

                //##########################################

                Log.wtf("@__@", "++++++   compassEvent:" + obj.toString());

                //############################################
            }
        }

        @Override
        public void canceledPreparingToShoot() {
        }

        @Override
        public void shotTakenPreviewReady(Bitmap bitmapPreview) {
            if (mBitmapCameraCaptureEffect != null) {
                mBitmapCameraCaptureEffect.recycle();
                mBitmapCameraCaptureEffect = null;
            }
            mBitmapCameraCaptureEffect = bitmapPreview;
        }

        @Override
        public void onFinishGeneratingEqui() {
            new SingleMediaScanner(ShooterActivity.this, mEquiPath);
            saveAngle();
            mIsStitching = false;
            //intent is only when a certain action occurs = in this case, tap to  finish image
            sendImageToServer(mEquiPath);
            Intent intentViewer = new Intent(ShooterActivity.this, ViewerActivity.class);
            intentViewer.putExtra("PanoramaName", mPanoramaName);
            startActivity(intentViewer);
            //show on full image view


            toastMessage("Panorama saved in gallery");


            System.out.println("soemthingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");

        }
    };


    public void sendImageToServer(String filePath) {
        Bitmap bm = null;

        try {
            bm = ImageLoader.init().from(filePath).requestSize(908, 374).getBitmap();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        String encodedImage = ImageBase64.encode(bm);
        HashMap<String, String> postData = new HashMap<String, String>();
        postData.put("file", encodedImage);
        PostResponseAsyncTask task = new PostResponseAsyncTask(ShooterActivity.this, postData, new AsyncResponse() {
            @Override
            public void processFinish(String s) {
//                Json js = Convert(s);
//                display(js.get("title"));
                ShooterActivity.testString = s;
                try {
                    JSONObject json = new JSONObject(s);
                    String test = (String)json.get("job_id");
                    ViewerActivity.rp = test;
                } catch (JSONException e) {
                    e.printStackTrace();
                }

//                ViewerActivity.tv.setText(s);
//                ViewerActivity.tv.invalidate();
            }
        });
        task.execute("https://panoramik.herokuapp.com/uploadImage");
        //task.execute("http://panoramik.herokuapp.com/status?job_id="+ String_JobUrl)
        task.setEachExceptionsHandler(new EachExceptionsHandler() {
            @Override
            public void handleIOException(IOException e) {
                System.out.println("111111111111111111111111111111111");
            }

            @Override
            public void handleMalformedURLException(MalformedURLException e) {
                System.out.println("2222222222222222222222222222");
            }

            @Override
            public void handleProtocolException(ProtocolException e) {
                System.out.println("3333333333333333333333333333");

            }

            @Override
            public void handleUnsupportedEncodingException(UnsupportedEncodingException e) {
                System.out.println("444444444444444444444444444444444444444");

            }
        });

    }



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //getting screen resolution
        mDisplay = getWindowManager().getDefaultDisplay();
        mDisplayMetrics = new DisplayMetrics();
        mDisplay.getMetrics(mDisplayMetrics);

        mHandler = new Handler();

        //File name formatter
        mSimpleDateFormat = new SimpleDateFormat("yyMMdd_HHmmss");

        mRelativeLayoutRoot = new RelativeLayout(this);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);
        mRelativeLayoutRoot.setLayoutParams(layoutParams);

        mDMDCapture = new DMD_Capture();
        mViewGroupCamera = mDMDCapture.initShooter(this, mCallbackInterface, getWindowManager().getDefaultDisplay().getRotation(), true, true);
        mRelativeLayoutRoot.addView(mViewGroupCamera);
        mViewGroupCamera.setOnClickListener(mCameraOnClickListener);

        //Text View instruction
        mTextViewInstruction = new TextView(this);
        mTextViewInstruction.setTextSize(32f);
        mTextViewInstruction.setGravity(Gravity.CENTER);
        setInstructionMessage(R.string.instruction_tap_start);
        mRelativeLayoutRoot.addView(mTextViewInstruction);

        // New text view
        mResultText = new TextView(this);
        mResultText.setTextSize(32f);
//        mResultText.setText("HELLO WORLD");
        mResultText.setGravity(Gravity.BOTTOM);
        mRelativeLayoutRoot.addView(mResultText);

        //View Preview Capture animation
        mViewPreviewCaptureEffect = new View(this);
        mViewPreviewCaptureEffect.setLayoutParams(new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        mViewPreviewCaptureEffect.setBackgroundColor(Color.WHITE);

        //ImageView Camera Capture animation
        mImageViewCameraCaptureEffect = new ImageViewBordered(this);
        mImageViewCameraCaptureEffect.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        mImageViewCameraCaptureEffect.setScaleType(ScaleType.FIT_XY);
        mBitmapCameraCaptureEffect = null;
        //
        mAnimationSetCameraCaptureEffect = new AnimationSet(true);
        mAnimationSetCameraCaptureEffect.setInterpolator(new AccelerateInterpolator());
        //Anim1
        mAlphaAnimationCameraCaptureEffect = new AlphaAnimation(0.65f, 0.0f);
        mAlphaAnimationCameraCaptureEffect.setDuration(400);
        mAlphaAnimationCameraCaptureEffect.setStartOffset(0);
        mAlphaAnimationCameraCaptureEffect.setRepeatCount(0);
        mAlphaAnimationCameraCaptureEffect.setFillAfter(true);
        mAlphaAnimationCameraCaptureEffect.setAnimationListener(new AnimationListener() {
            public void onAnimationStart(Animation animation) {
                //mImageViewCameraCaptureEffect.setImageBitmap(mBitmapCameraCaptureEffect);
            }

            public void onAnimationRepeat(Animation animation) {
            }

            public void onAnimationEnd(Animation animation) {
                if (mViewPreviewCaptureEffect.getParent() != null) {
                    mHandler.post(new Runnable() {
                        public void run() {
                            if (mViewPreviewCaptureEffect.getParent() != null) {
                                mViewGroupCamera.removeView(mViewPreviewCaptureEffect);
                                mViewGroupCamera.invalidate();
                            }
                        }
                    });
                }
            }
        });
        //Anim2
        Animation animationTranslate = new TranslateAnimation(
                Animation.RELATIVE_TO_PARENT, 0.0f,
                Animation.RELATIVE_TO_PARENT, 1.0f,
                Animation.RELATIVE_TO_PARENT, 0.0f,
                Animation.RELATIVE_TO_PARENT, 1.0f);
        animationTranslate.setInterpolator(new AccelerateInterpolator());
        animationTranslate.setDuration(550);
        animationTranslate.setStartOffset(0);
        animationTranslate.setFillAfter(true);
        animationTranslate.setRepeatCount(0);
        animationTranslate.setAnimationListener(new AnimationListener() {
            public void onAnimationStart(Animation animation) {
            }

            public void onAnimationRepeat(Animation animation) {
            }

            public void onAnimationEnd(Animation animation) {
                mHandler.post(new Runnable() {
                    public void run() {
                        if (mImageViewCameraCaptureEffect.getParent() != null) {
                            mViewGroupCamera.removeView(mImageViewCameraCaptureEffect);
                            mImageViewCameraCaptureEffect.setImageDrawable(null);
                        }
                        if (mBitmapCameraCaptureEffect != null) {
                            mBitmapCameraCaptureEffect.recycle();
                            mBitmapCameraCaptureEffect = null;
                        }
                    }
                });
            }
        });

        //Anim3
        Animation animationScale = new ScaleAnimation(
                1.0f, 0.01f,
                1.0f, 0.01f,
                Animation.RELATIVE_TO_SELF, 1.0f,
                Animation.RELATIVE_TO_SELF, 1.0f);
        animationScale.setInterpolator(new AccelerateInterpolator());
        animationScale.setDuration(550);
        animationScale.setStartOffset(0);
        animationScale.setFillAfter(true);
        animationScale.setRepeatCount(0);

        //setting animations
        mAnimationSetCameraCaptureEffect.addAnimation(animationTranslate);
        mAnimationSetCameraCaptureEffect.addAnimation(animationScale);

        if (mDMDCapture.isTablet()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }

        setContentView(mRelativeLayoutRoot);
        //showAngle();
        System.out.println("ALLSADJFKAS;LDKFJAS;LDKFJA;SLDKFJA;SLDKFJA;LSDKFJ");
        tts = new TextToSpeech(getApplicationContext(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if(status != TextToSpeech.ERROR) {
                    tts.setLanguage(Locale.US);
                    tts.setSpeechRate(1/2);
                }
            }
        });
        System.out.println("ALLSADJFKAS;LDKFJAS;LDKFJA;SLDKFJA;SLDKFJA;LSDKFJ");
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mIsCapturing) {
            //clear the flag to prevent the screen of being on
            getWindow().clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            mIsCapturing = false;
            setInstructionMessage(R.string.instruction_tap_start);
            //tts.speak("Tap to start", TextToSpeech.QUEUE_FLUSH, null);

        }
        mDMDCapture.stopShooting();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mDMDCapture.restart(this, mDisplayMetrics.widthPixels, mDisplayMetrics.heightPixels);
        mTextViewInstruction.setVisibility(View.VISIBLE);
    }

    @Override
    public void onBackPressed() {
        if (mIsStitching) {
            return;
        }
        if (mIsCapturing) {
            //clear the flag to prevent the screen of being on
            getWindow().clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            mDMDCapture.restart(this, mDisplayMetrics.widthPixels, mDisplayMetrics.heightPixels);
            mIsCapturing = false;
            setInstructionMessage(R.string.instruction_tap_start);
            //tts.speak("Tap to start", TextToSpeech.QUEUE_FLUSH, null);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void setInstructionMessage(int msgID) {
        if (mCurrentInstructionMessageID == msgID)
            return;

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(mDisplayMetrics.widthPixels, RelativeLayout.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.CENTER_HORIZONTAL);

        if (msgID == R.string.instruction_empty || msgID == R.string.instruction_hold_vertically || msgID == R.string.instruction_tap_start
                || msgID == R.string.instruction_focusing) {
            params.addRule(RelativeLayout.CENTER_VERTICAL);

            //tts.speak("please please please please work", TextToSpeech.QUEUE_FLUSH, null);
        } else {
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        }

        mTextViewInstruction.setLayoutParams(params);
        mTextViewInstruction.setText(msgID);
        mCurrentInstructionMessageID = msgID;
    }

    private void toastMessage(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    private void saveAngle() {
        try {
            ExifInterface ei = new ExifInterface(mEquiPath);
            ei.setAttribute("UserComment", lAngle + "");
            ei.setAttribute("CopyRight", lAngle + "");
            ei.saveAttributes();
        } catch (IOException e) {
            e.printStackTrace();

        }

    }
}
