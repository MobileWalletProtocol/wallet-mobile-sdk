package com.coinbase.android.beta.utils

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class SpacesItemDecoration(private val spacing: Int, private val marginSpacing: Int) : RecyclerView.ItemDecoration() {

    override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
        outRect.left = if (parent.getChildLayoutPosition(view) == 0) marginSpacing else spacing
    }
}