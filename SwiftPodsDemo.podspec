#
# Be sure to run `pod lib lint SwiftPodsDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftPodsDemo'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SwiftPodsDemo.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/2574282239@qq.com/SwiftPodsDemo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '2574282239@qq.com' => '2574282239@qq.com' }
  s.source           = { :git => 'https://github.com/2574282239@qq.com/SwiftPodsDemo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftPodsDemo/Classes/**/*'
  
  s.static_framework = true
  s.dependency "BaiduMapKit"

  s.pod_target_xcconfig = {
         'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup',
         'ENABLE_BITCODE' => 'NO',
  }
  
  # 开发的时候打开，lint或者push的时候注释
  s.prepare_command = 'sh mk_modulemap.sh Example/Pods/BaiduMapKit/BaiduMapKit '
  
end
