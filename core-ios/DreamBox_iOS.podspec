#
# Be sure to run `pod lib lint DreamBox_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DreamBox_iOS'
  s.version          = '0.1.0'
  s.summary          = 'DreamBox_iOS Pod'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is DreamBox_iOS Pod
                       DESC

  s.homepage         = 'https://git.xiaojukeji.com/DreamBox/dreambox_ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fangshaosheng' => 'fangshaosheng@didichuxing.com' }
  s.source           = { :git => 'https://git.xiaojukeji.com/DreamBox/dreambox_ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DreamBox_iOS/Classes/**/*'
  s.dependency 'SDWebImage' ,'> 5.0'
  s.dependency 'Masonry'
  s.dependency 'YogaKit'
  
  s.resource_bundles = {
    'DreamBox_iOS' => ['DreamBox_iOS/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
