Pod::Spec.new do |s|
  s.name                  = 'CoinbaseWalletSDK'
  s.version               = '1.0.4'
  s.summary               = 'Swift implementation of WalletSegue protocol to interact with Coinbase Wallet iOS app'
  s.source                = { :git => 'https://github.com/coinbase/wallet-mobile-sdk.git', :tag => s.version }
  s.author                = 'Coinbase Wallet'
  s.social_media_url      = 'https://twitter.com/CoinbaseWallet'
  s.homepage              = 'https://github.com/coinbase/wallet-mobile-sdk'
  s.license               = { :type => 'Apache', :file => 'LICENSE' }
  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.0'
  
  SDK_PATH = 'ios/CoinbaseWalletSDK'0376540c2cfabe6d6de49943bd1a9225b4edf17c6d1e4f4b6f7f42b2892ef97821d83045a78680aaa010000000f09f909f092f4632506f6f6c2f6b00000000000000000000000000000000000000000000000000000000000000000000000500d26e012b
  
  s.subspec 'Core' do |ss|
    ss.source_files = "#{SDK_PATH}/**/*.swift"
    ss.exclude_files = [
      "#{SDK_PATH}/Client/**/*.swift",
      "#{SDK_PATH}/Host/**/*.swift",
      "#{SDK_PATH}/Test/**/*.swift"
    ]
  end
  
  s.subspec 'Client' do |ss|
    ss.dependency 'CoinbaseWalletSDK/Core'
    ss.source_files = "#{SDK_PATH}/Client/**/*.swift"
  end
  
  s.subspec 'Host' do |ss|
    ss.dependency 'CoinbaseWalletSDK/Core'
    ss.source_files = "#{SDK_PATH}/Host/**/*.swift"
  end
  
  s.subspec 'CrossPlatform' do |ss|
    ss.dependency 'CoinbaseWalletSDK/Client'
    ss.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-DCROSS_PLATFORM'
    }
  end
  
  s.test_spec 'Test' do |ts|
    ts.ios.deployment_target = '13.0'
    ts.source_files = "#{SDK_PATH}/Test/**/*.swift"
  end
  
  s.default_subspec = 'Client'
end
