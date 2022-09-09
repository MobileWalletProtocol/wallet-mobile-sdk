Pod::Spec.new do |s|
  s.name                  = 'CoinbaseWalletSDK'
  s.version               = '0.3.3'
  s.summary               = 'Swift implementation of WalletSegue protocol to interact with Coinbase Wallet iOS app'
  s.source                = { :git => 'https://github.com/coinbase/wallet-mobile-sdk.git', :tag => s.version }
  s.author                = 'Coinbase Wallet'
  s.social_media_url      = 'https://twitter.com/CoinbaseWallet'
  s.homepage              = 'https://github.com/coinbase/wallet-mobile-sdk'
  s.license               = { :type => 'Apache', :file => 'LICENSE' }
  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.0'
  
  s.subspec 'Client' do |ss|
    ss.source_files = 'ios/CoinbaseWalletSDK/**/*.swift'
    ss.exclude_files = 'ios/CoinbaseWalletSDK/Host/**/*.swift'
  end
  
  s.subspec 'Host' do |ss|
    ss.dependency 'CoinbaseWalletSDK/Client'
    ss.source_files = 'ios/CoinbaseWalletSDK/Host/**/*.swift'
  end
  
  s.default_subspec = 'Client'
end
