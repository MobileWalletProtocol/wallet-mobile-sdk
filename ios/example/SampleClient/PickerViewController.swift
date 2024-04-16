//
//  PickerViewController.swift
//  SampleClient
//
//  Created by Jungho Bang on 11/22/22.
//

import UIKit
import CoinbaseWalletSDK

class PickerViewController: UITableViewController {
    let wallets = Wallet.defaultWallets() + [
        Wallet(
            name: "Sample Wallet",
            iconUrl: URL(string: "https://...")!,
            url: URL(string: "samplewallet://wsegue")!, // Should use universal links in production
            mwpScheme: URL(string: "samplewallet://")!,
            appStoreUrl: URL(string: "https://apps.apple.com/app/...")!
        )
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = self.wallets[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! PickerTableViewCell
        cell.nameTextLabel.text = wallet.name
        cell.iconImageView.load(url: wallet.iconUrl)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "pushToWalletDetail",
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell),
            let wvc = segue.destination as? WalletViewController
        else { return }
        
        wvc.wallet = wallets[indexPath.row]
    }
}

class PickerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}
