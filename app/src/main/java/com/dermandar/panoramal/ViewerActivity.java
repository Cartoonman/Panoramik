package com.dermandar.panoramal;

import android.app.Activity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.dermandar.dmd_lib.CallbackInterfaceViewer;
import com.dermandar.dmd_lib.DMD_Viewer;

public class ViewerActivity extends Activity {
    private RelativeLayout mRelativeLayoutRoot;

    private DMD_Viewer mDMDViewer;
    private View mViewViewer;

    public static TextView tv;

    private Display mDisplay;
    private DisplayMetrics mDisplayMetrics;
    private CallbackInterfaceViewer mCallbackInterfaceViewer = new CallbackInterfaceViewer() {
        @Override
        public void onSingleTapConfirmed() {

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
        ViewerActivity.tv.setTextSize(32f);
        ViewerActivity.tv.setText(ShooterActivity.testString);
        mRelativeLayoutRoot.addView(ViewerActivity.tv);
        /////////////////////
        setContentView(mRelativeLayoutRoot);
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
