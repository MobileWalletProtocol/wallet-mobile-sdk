Pod::Spec.new do |s|
  s.name                  = 'CoinbaseWalletSDK'
  s.version               = '0.2.1'
  s.summary               = 'Swift implementation of WalletSegue protocol to interact with Coinbase Wallet iOS app'
  s.source                = { :git => 'https://github.com/coinbase/wallet-mobile-sdk.git', :tag => s.version }
  s.author                = 'Coinbase Wallet'
  s.social_media_url      = 'https://twitter.com/CoinbaseWallet'
  s.homepage              = 'https://www.coinbase.com/wallet/developers'
  s.license               = { :type => 'Apache', :file => 'LICENSE' }
  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.0'
  s.source_files          = 'ios/CoinbaseWalletSDK/**/*.swift'
end
