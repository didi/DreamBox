package com.didi.carmate.db_debug;

import android.annotation.SuppressLint;
import android.util.Log;

import com.didi.carmate.db.common.utils.DbUiThreadHandler;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import java.net.URI;

/**
 * author: chenjing
 * date: 2020/11/26
 */
class DBWebSocket {
    private static final String TAG = "DBWebSocket";
    private final static DBWebSocket webSocket = new DBWebSocket();
    private WebSocketClient socketClient;

    static DBWebSocket getWebSocket() {
        return webSocket;
    }

    boolean isConnect(){
        if(null != socketClient) {
            return socketClient.isOpen();
        }
        return false;
    }

    void connect(String address, SocketEvent socketEvent) {
        if (socketClient != null && socketClient.isOpen()) {
            DbUiThreadHandler.post(() -> socketEvent.onOpen(null));
            return;
        }

        socketClient = new WebSocketClient(URI.create(address)) {
            @Override
            public void onOpen(ServerHandshake handshakeData) {
                DbUiThreadHandler.post(() -> socketEvent.onOpen(handshakeData));
            }

            @SuppressLint("RestrictedApi")
            @Override
            public void onMessage(String message) {
                DbUiThreadHandler.post(() -> socketEvent.onMessage(message));
            }


            @Override
            public void onClose(int code, String reason, boolean remote) {
                DbUiThreadHandler.post(() -> socketEvent.onClose(code, reason, remote));
            }

            @Override
            public void onError(Exception ex) {
                DbUiThreadHandler.post(() -> socketEvent.onError(ex));
            }
        };

        new Thread(() -> {
            try {
                socketClient.connectBlocking();
            } catch (InterruptedException e) {
                e.printStackTrace();
                Log.i(TAG, "错误： " + e.toString());
            }
        }).start();
    }

    void close() {
        if (socketClient != null) {
            socketClient.close();
        }
    }

    interface SocketEvent {
        void onOpen(ServerHandshake handshakeData);

        void onMessage(String message);

        void onClose(int code, String reason, boolean remote);

        void onError(Exception ex);
    }
}
