Pod::Spec.new do |spec|
  spec.name         = 'KVOController'
  spec.version      = '1.0.0'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/facebook/KVOController'
  spec.authors      = { 'Kimon Tsinteris' => 'kimon@mac.com' }
  spec.summary      = 'Simple, modern, thread-safe key-value observing.'
  spec.source       = { :git => 'https://github.com/facebook/KVOController.git', :tag => 'v1.0.0' }
  spec.source_files = 'FBKVOController/FBKVOController.{h,m}'
  spec.requires_arc = true
  
  spec.ios.deployment_target = '6.0'
  spec.osx.deployment_target = '10.7'
end
