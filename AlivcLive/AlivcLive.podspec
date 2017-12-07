Pod::Spec.new do |spec|
  spec.name         = 'AlivcLive'
  spec.version      = '1.0'
  spec.license       = { :type => 'Copyright', :text => 'ZJaDe Inc. 2017' }
  spec.summary      = '阿里云直播封装'
  spec.description  = '阿里云直播封装'
  spec.homepage     = 'https://help.aliyun.com/product/29949.html'
  spec.author       = {'ZJaDe Inc.' => 'info@hyphenate.io'}
  spec.source       = {:path=> './' }
  spec.platform     = :ios, '8.0'
  spec.requires_arc = true
  spec.vendored_frameworks = 'AlivcLibRtmp.framework', 'AlivcLivePusher.framework'
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
  spec.user_target_xcconfig = {'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO'}
end
