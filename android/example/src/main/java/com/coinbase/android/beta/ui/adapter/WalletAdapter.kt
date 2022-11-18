package com.coinbase.android.beta.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import coil.load
import coil.transform.CircleCropTransformation
import com.coinbase.android.beta.databinding.ItemWalletBinding
import com.coinbase.android.nativesdk.Wallet

class WalletAdapter(
    private val walletClickListener: (wallet: Wallet) -> Unit
) : ListAdapter<Wallet, WalletAdapter.WalletViewHolder>(WalletDiffCallBack()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): WalletViewHolder {
        val binding = ItemWalletBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return WalletViewHolder(binding)
    }

    override fun onBindViewHolder(holder: WalletViewHolder, position: Int) {
        val currentItem = getItem(position)
        holder.itemView.setOnClickListener { walletClickListener(currentItem) }
        holder.bind(currentItem)
    }

    class WalletViewHolder(private val binding: ItemWalletBinding) : RecyclerView.ViewHolder(binding.root) {

        fun bind(wallet: Wallet) {
            binding.walletImage.load(wallet.iconUrl) {
                crossfade(true)
                transformations(CircleCropTransformation())
            }

            binding.walletName.text = wallet.name
        }
    }

    private class WalletDiffCallBack : DiffUtil.ItemCallback<Wallet>() {
        override fun areItemsTheSame(oldItem: Wallet, newItem: Wallet): Boolean =
            oldItem == newItem

        override fun areContentsTheSame(oldItem: Wallet, newItem: Wallet): Boolean =
            oldItem.url == newItem.url
    }
}
