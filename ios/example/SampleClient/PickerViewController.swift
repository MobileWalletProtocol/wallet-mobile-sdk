//
//  PickerViewController.swift
//  SampleClient
//
//  Created by Jungho Bang on 11/22/22.
//

import UIKit
import CoinbaseWalletSDK

class PickerViewController: UITableViewController {
    
    let wallets = Wallet.defaultWallets()
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell")!
        
        cell.textLabel?.text = self.wallets[indexPath.row].name
        
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

