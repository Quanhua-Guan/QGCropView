#
# Be sure to run `pod lib lint QGCropView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QGCropView'
  s.version          = '0.1.0'
  s.summary          = '图片裁剪+视频裁剪+可扩展任意可视内容裁剪'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
图片裁剪,视频裁剪,Any裁剪
                       DESC

  s.homepage         = 'https://quanhua-guan.github.io/QGCropView/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '宇园' => 'xinmuheart@163.com' }
  s.source           = { :git => 'git@github.com:Quanhua-Guan/QGCropView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/xinmuheart'

  s.ios.deployment_target = '8.0'
  
  s.source_files = 'QGCropView/Classes/*.{m,h}', 'QGCropView/Classes/**/*.{m,h}'
  s.resources = 'QGCropView/Assets/*.bundle', 'QGCropView/Classes/*.xib', 'QGCropView/Classes/**/*.xib'
  s.public_header_files = 'QGCropView/Classes/*.h'
  # s.resource_bundles = {
  #   'QGCropView' => ['QGCropView/Assets/*.png']
  # }
  #s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'Masonry'
  s.dependency 'SVProgressHUD'
  s.dependency 'SDVersion'

  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
end
