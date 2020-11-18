package com.didi.carmate.playground.page;

import android.content.Intent;
import android.content.pm.PackageManager;
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
import com.didi.carmate.playground.view.PlayGroundView;
import com.didi.dreambox.playground.R;
import com.uuzuche.lib_zxing.activity.CaptureActivity;
import com.uuzuche.lib_zxing.activity.CodeUtils;
import com.uuzuche.lib_zxing.activity.ZXingLibrary;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;

public class PlayGroundActivity extends AppCompatActivity implements View.OnClickListener {
    private static final int PERMISSIONS_REQUEST_CAMERA = 101;

    String tag = this.getClass().getSimpleName();
    TextView scanBtn, refreshBtn, confirmBtn;
    EditText contentEd;
    PlayGroundView dbView;
    private WebSocketClient socketClient;

    private int SCAN_REQUEST_CODE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_playground);
        scanBtn = findViewById(R.id.db_playground_scan);
        scanBtn.setOnClickListener(this);
        refreshBtn = findViewById(R.id.db_playground_refresh);
        refreshBtn.setOnClickListener(this);
        confirmBtn = findViewById(R.id.db_playground_confirm);
        confirmBtn.setOnClickListener(this);
        contentEd = findViewById(R.id.db_playground_content);
        dbView = findViewById(R.id.db_playground_view);
        ZXingLibrary.initDisplayOpinion(this);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.db_playground_scan) {
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
        } else if (id == R.id.db_playground_refresh) {
            send();
        } else if (id == R.id.db_playground_confirm) {
            confirm();
        }
    }

    private void connect(String address) {
        if (socketClient != null && socketClient.isOpen()) {
            Toast.makeText(PlayGroundActivity.this,
                    getString(R.string.debug_toast_connect_tip), Toast.LENGTH_LONG).show();
            return;
        }
        socketClient = new WebSocketClient(URI.create(address)) {

            @Override
            public void onOpen(ServerHandshake handshakedata) {
                Log.i(tag, "打开通道： " + handshakedata);
                DbUiThreadHandler.post(() -> Toast.makeText(PlayGroundActivity.this,
                        getString(R.string.debug_toast_connect_tip), Toast.LENGTH_LONG).show());
            }

            @Override
            public void onMessage(String message) {
                Log.i(tag, "接受服务信息： " + message);
                String model = getString(R.string.debug_content_hint);
                String type = "";

                if (!TextUtils.isEmpty(message)) {
                    try {
                        JSONObject json = new JSONObject(message);
                        type = json.optString("type");
                        model = json.optString("data");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
                Log.i(tag, "接受服务信息 解析完毕 ： " + model);
                updateView(model, type); //更新view
                DbUiThreadHandler.post(() -> Toast.makeText(PlayGroundActivity.this,
                        getString(R.string.debug_toast_new_msg), Toast.LENGTH_LONG).show());

            }


            @Override
            public void onClose(int code, String reason, boolean remote) {
                Log.i(tag, "通道关闭： " + reason);
                DbUiThreadHandler.post(() -> Toast.makeText(PlayGroundActivity.this,
                        getString(R.string.debug_toast_close_tip), Toast.LENGTH_LONG).show());
            }

            @Override
            public void onError(Exception ex) {
                Log.i(tag, "错误： " + ex.toString());
                DbUiThreadHandler.post(() -> Toast.makeText(PlayGroundActivity.this,
                        getString(R.string.debug_toast_connect_error), Toast.LENGTH_LONG).show());
            }
        };


        new Thread(() -> {
            try {
                socketClient.connectBlocking();
            } catch (InterruptedException e) {
                e.printStackTrace();
                Log.i(tag, "错误： " + e.toString());
            }

        }).start();
    }

    private void send() {
        if (socketClient != null && socketClient.isOpen()) {
            socketClient.send("ask");
        } else {
            Toast.makeText(PlayGroundActivity.this,
                    getString(R.string.debug_toast_send_tip), Toast.LENGTH_LONG).show();
        }
    }

    private void close() {
        if (socketClient != null) {
            socketClient.close();
        }
    }

    private void scan() {
        Intent intent = new Intent(this, CaptureActivity.class);
        startActivityForResult(intent, SCAN_REQUEST_CODE);
    }

    private void confirm() {
        if (contentEd != null && contentEd.getText() != null) {
            String address = contentEd.getText().toString();
            if (!TextUtils.isEmpty(address)) {
                connect(address);
            } else {
                Toast.makeText(PlayGroundActivity.this,
                        getString(R.string.db_display_edit_tip),
                        Toast.LENGTH_LONG).show();
            }
        }


    }

    private void updateView(String template, String type) {
        if (!TextUtils.isEmpty(template)) {
            if (TextUtils.equals("compiled", type)) {
                dbView.render(template);
            } else if (TextUtils.equals("ext", type)) {
                dbView.setData(template);
            }
        }
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
                    contentEd.setText(result);
                    connect(result);
                } else if (bundle.getInt(CodeUtils.RESULT_TYPE) == CodeUtils.RESULT_FAILED) {
                    // 扫描失败
                    Toast.makeText(PlayGroundActivity.this,
                            getString(R.string.db_display_scan_fail),
                            Toast.LENGTH_LONG).show();
                }
            }
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

    @Override
    protected void onDestroy() {
        super.onDestroy();
        close();
    }
}
