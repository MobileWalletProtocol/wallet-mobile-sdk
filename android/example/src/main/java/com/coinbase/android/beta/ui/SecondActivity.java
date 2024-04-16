package com.coinbase.android.beta.ui;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.coinbase.android.beta.R;
import com.coinbase.android.nativesdk.CoinbaseWalletSDK;
import com.coinbase.android.nativesdk.DefaultWallets;
import com.coinbase.android.nativesdk.message.request.Action;
import com.coinbase.android.nativesdk.message.request.Web3JsonRPC;
import com.coinbase.android.nativesdk.message.response.ActionResult;

import java.util.ArrayList;

public class SecondActivity extends AppCompatActivity {

    final int CBW_ACTIVITY_RESULT_CODE = 9182736;

    CoinbaseWalletSDK client;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        CoinbaseWalletSDK.setOpenIntentCallback(intent -> startActivityForResult(intent, CBW_ACTIVITY_RESULT_CODE));

        client = CoinbaseWalletSDK.getClient(DefaultWallets.coinbaseWallet);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        CoinbaseWalletSDK.setOpenIntentCallback(null);
    }

    @Override
    protected void onStart() {
        super.onStart();

        ArrayList<Action> actions = new ArrayList<>();
        actions.add(new Web3JsonRPC.RequestAccounts().action(false));
        actions.add(new Web3JsonRPC.PersonalSign("", "0xdeadbeef").action(false));


        client.initiateHandshake(
                actions,
                (results, account) -> {
                    for (ActionResult result : results) {
                        if (result instanceof ActionResult.Result) {
                            ((ActionResult.Result) result).getValue();
                        }

                        if (result instanceof ActionResult.Error) {
                            ((ActionResult.Error) result).getCode();
                            ((ActionResult.Error) result).getMessage();
                        }
                    }
                },
                error -> {
                }
        );
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode != CBW_ACTIVITY_RESULT_CODE) {
            return;
        }

        if (data == null) {
            return;
        }

        Uri url = data.getData();
        client.handleResponse(url);
    }
}
