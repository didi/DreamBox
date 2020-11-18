package com.didi.carmate.db_debug;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.didi.carmate.db.common.utils.DbUiThreadHandler;
import com.didi.carmate.db.common.utils.DbViewUtil;
import com.didi.carmate.dreambox.shell.DreamBox;
import com.didi.carmate.dreambox.shell.DreamBoxView;
import com.uuzuche.lib_zxing.activity.CaptureActivity;
import com.uuzuche.lib_zxing.activity.CodeUtils;
import com.uuzuche.lib_zxing.activity.ZXingLibrary;

import org.angmarch.views.NiceSpinner;
import org.angmarch.views.OnSpinnerItemSelectedListener;
import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DebugActivity extends AppCompatActivity implements View.OnClickListener {

    private String tag = this.getClass().getSimpleName();
    private static final int PERMISSIONS_REQUEST_CAMERA = 101;

    TextView bindBtn, refreshBtn, scanBtn;
    EditText addressEd;
    NiceSpinner accessKeySp, modelIdSp;
    private List<String> defaultData = new ArrayList<>();
    private List<String> accessKeyData = new ArrayList<>();
    private WebSocketClient socketClient;
    private String selectedAccessKey;
    private String selectedModelId;
    private Map<String, List<String>> dreamBoxList;
    private String templateStr = "";
    private DreamBoxView dreamBoxView;
    private TextView statusTip;


    private int SCAN_REQUEST_CODE = 1;
    private boolean dataValid = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_debug);
        bindBtn = findViewById(R.id.db_debug_bind);
        bindBtn.setOnClickListener(this);
        refreshBtn = findViewById(R.id.db_debug_refresh);
        refreshBtn.setOnClickListener(this);
        scanBtn = findViewById(R.id.db_debug_scan);
        scanBtn.setOnClickListener(this);
        addressEd = findViewById(R.id.db_debug_address);
        statusTip = findViewById(R.id.db_debug_tip);

        accessKeySp = findViewById(R.id.db_debug_access_key);
        modelIdSp = findViewById(R.id.db_debug_model_id);

        ZXingLibrary.initDisplayOpinion(this);

        initData();

    }

    @SuppressLint("RestrictedApi")
    private void initData() {

        dreamBoxList = DreamBox.getInstance().getAllRenderDreamBox();
        accessKeyData.clear();
        if (dreamBoxList.size() > 0) {
            Set<String> keys = dreamBoxList.keySet();
            for (String key : keys) {
                if (!TextUtils.isEmpty(key)) {
                    accessKeyData.add(key);
                }
            }
        }

        // 数据是否有效
        dataValid = accessKeyData != null && accessKeyData.size() > 0;
        defaultData.add("无数据");

        // AccessKey Sp
        if (dataValid) {
            accessKeySp.attachDataSource(accessKeyData);
            accessKeySp.setOnSpinnerItemSelectedListener(new OnSpinnerItemSelectedListener() {
                @Override
                public void onItemSelected(NiceSpinner parent, View view, int position, long id) {
                    if (position < accessKeyData.size()) {
                        selectedAccessKey = accessKeyData.get(position);
                        List<String> modelIds = getModelIdData(selectedAccessKey);
                        if (modelIds != null && modelIds.size() > 0) {
                            modelIdSp.attachDataSource(modelIds);
                        } else {
                            modelIdSp.attachDataSource(defaultData);
                        }
                    }
                }
            });
        } else {
            accessKeySp.attachDataSource(defaultData);
        }
        accessKeySp.setSelectedIndex(0);
        selectedAccessKey = accessKeySp.getText() == null ? "" :
                accessKeySp.getText().toString();


        // 模版id Sp
        final List<String> modelIds = getModelIdData(selectedAccessKey);
        if (dataValid && modelIds != null && modelIds.size() > 0) {
            modelIdSp.attachDataSource(modelIds);
            modelIdSp.setOnSpinnerItemSelectedListener(new OnSpinnerItemSelectedListener() {
                @Override
                public void onItemSelected(NiceSpinner parent, View view, int position, long id) {
                    if (position < modelIds.size()) {
                        selectedModelId = modelIds.get(position);
                    }
                }
            });
        } else {
            modelIdSp.attachDataSource(defaultData);
        }
        modelIdSp.setSelectedIndex(0);
        selectedModelId = modelIdSp.getText() == null ? "" :
                modelIdSp.getText().toString();

        // scan
        Drawable scanDrawable = getResources().getDrawable(R.drawable.db_scan);
        scanDrawable.setBounds(0, 0, DbViewUtil.dp2px(this, 30),
                DbViewUtil.dp2px(this, 30));
        scanBtn.setCompoundDrawables(null, null, scanDrawable, null);


    }

    private List<String> getModelIdData(String accessKey) {
        if (dreamBoxList != null) {
            return dreamBoxList.get(accessKey);
        } else {
            return null;
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.db_debug_scan) {
            if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (ContextCompat.checkSelfPermission(this,
                        android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this,
                            new String[]{android.Manifest.permission.CAMERA}, PERMISSIONS_REQUEST_CAMERA);
                } else {
                    scan();
                }
            } else {
                scan();
            }
        } else if (id == R.id.db_debug_bind) {
            bind();
        } else if (id == R.id.db_debug_refresh) {
            initData();
            close();
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_REQUEST_CAMERA && grantResults.length > 0 &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            scan();
        } else {
            Log.e(tag, "错误：相机权限获取失败");
        }
    }

    @SuppressLint("RestrictedApi")
    private void bind() {
        if (!dataValid) {
            Toast.makeText(DebugActivity.this,
                    "无效的数据", Toast.LENGTH_LONG).show();
            return;
        }

        if (!TextUtils.isEmpty(selectedAccessKey) &&
                !TextUtils.equals("无数据", selectedAccessKey) &&
                !TextUtils.isEmpty(selectedModelId) &&
                !TextUtils.equals("无数据", selectedModelId)
        ) {

            dreamBoxView = DreamBox.getInstance().
                    getDreamBoxView(selectedAccessKey, selectedModelId);
            if (dreamBoxView != null) {
                dreamBoxView.reloadWithTemplate(templateStr);
                Toast.makeText(DebugActivity.this,
                        "绑定成功", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(DebugActivity.this,
                        "没有获取到DBView", Toast.LENGTH_LONG).show();
            }
        } else {
            Log.i(tag, "无效的key selectedAccessKey： " + selectedAccessKey +
                    " selectedModelId：" + selectedModelId);

            Toast.makeText(DebugActivity.this,
                    "无效的key或者模版id", Toast.LENGTH_LONG).show();
        }

    }

    private void connect(String address) {

        if (socketClient != null && socketClient.isOpen()) {
            Toast.makeText(DebugActivity.this,
                    getString(R.string.debug_toast_connect_tip), Toast.LENGTH_LONG).show();
            return;
        }
        socketClient = new WebSocketClient(URI.create(address)) {

            @Override
            public void onOpen(ServerHandshake handshakedata) {
                Log.i(tag, "打开通道： " + handshakedata);
                DbUiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(DebugActivity.this,
                                getString(R.string.debug_toast_connect_tip),
                                Toast.LENGTH_LONG).show();
                    }
                });
            }

            @SuppressLint("RestrictedApi")
            @Override
            public void onMessage(String message) {
                Log.i(tag, "接受服务信息： " + message);
                if (!TextUtils.isEmpty(message)) {
                    try {
                        JSONObject json = new JSONObject(message);
                        templateStr = json.optString("data");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
                if (dreamBoxView != null && !TextUtils.isEmpty(templateStr)) {
                    dreamBoxView.reloadWithTemplate(templateStr);
                }
                Log.i(tag, "接受服务信息 解析完毕 ： " + templateStr);
                DbUiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        statusTip.setHint("连接成功，请绑定进行调试");
                        Toast.makeText(DebugActivity.this,
                                getString(R.string.debug_toast_new_msg),
                                Toast.LENGTH_LONG).show();
                    }
                });


            }


            @Override
            public void onClose(int code, String reason, boolean remote) {
                Log.i(tag, "通道关闭： " + reason);
                DbUiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        statusTip.setHint("连接断开，请扫码连接");
                        templateStr = "";
                        Toast.makeText(DebugActivity.this,
                                getString(R.string.debug_toast_close_tip), Toast.LENGTH_LONG).show();
                    }
                });

            }

            @Override
            public void onError(Exception ex) {
                Log.i(tag, "错误： " + ex.toString());
                DbUiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        statusTip.setHint("连接断开，请扫码连接");
                        templateStr = "";
                        Toast.makeText(DebugActivity.this,
                                getString(R.string.debug_toast_connect_error), Toast.LENGTH_LONG).show();
                    }
                });
            }
        };

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    socketClient.connectBlocking();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    Log.i(tag, "错误： " + e.toString());
                }
            }
        }).start();
    }

//    private void send(final String msg) {
//        if (socketClient != null && socketClient.isOpen()) {
//            socketClient.send(msg);
//        } else {
//            Toast.makeText(DebugActivity.this,
//                    getString(R.string.debug_toast_send_tip), Toast.LENGTH_LONG).show();
//        }
//    }

    private void close() {
        if (socketClient != null) {
            socketClient.close();
        }
        Toast.makeText(DebugActivity.this,
                getResources().getString(R.string.debug_toast_close_tip), Toast.LENGTH_LONG).show();
    }

    private void scan() {
        Intent intent = new Intent(this, CaptureActivity.class);
        startActivityForResult(intent, SCAN_REQUEST_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SCAN_REQUEST_CODE) {
            //处理扫描结果（在界面上显示）
            if (null != data) {
                Bundle bundle = data.getExtras();
                if (bundle == null) {
                    return;
                }
                if (bundle.getInt(CodeUtils.RESULT_TYPE) == CodeUtils.RESULT_SUCCESS) {
                    String result = bundle.getString(CodeUtils.RESULT_STRING);
                    Log.i(tag, "二维码解析结果: ： " + result);
                    addressEd.setText(result);
                    connect(result);
                } else if (bundle.getInt(CodeUtils.RESULT_TYPE) == CodeUtils.RESULT_FAILED) {
                    Toast.makeText(DebugActivity.this,
                            "扫描失败", Toast.LENGTH_LONG).show();
                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        close();
    }
}
