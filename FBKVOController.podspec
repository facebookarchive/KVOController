Pod::Spec.new do |spec|
  spec.name         = 'KVOController'
  spec.version      = '0.0.2'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/facebook/KVOController'
  spec.authors      = { 'Kimon Tsinteris' => 'kimon@mac.com' }
  spec.summary      = 'Key-value observing is a particularly useful technique for communicating between layers in a Model-View-Controller application. KVOController builds on the time-tested Cocoa key-value observing implementation. It offers a simple, convenient API, that is also thread safe.'
  spec.source       = { :git => 'https://github.com/facebook/KVOController.git', :commit => '0292130f472f46c8aac6fb0b647caf120babfdab' }
  spec.source_files = 'FBKVOController/FBKVOController.{h,m}'
  spec.requires_arc = true
  
  spec.ios.deployment_target = '6.0'
  spec.osx.deployment_target = '10.7'
end
