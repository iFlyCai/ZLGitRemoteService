#
# Be sure to run `pod lib lint ZLGitRemoteService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZLGitRemoteService'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZLGitRemoteService.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'ZLGitRemoteService'

  s.homepage         = 'https://github.com/existorlive/ZLGitRemoteService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'existorlive' => '2068531506@qq.com' }
  s.source           = { :git => 'https://github.com/existorlive/ZLGitRemoteService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.module_name = 'ZLGitRemoteService'
  s.source_files = 'ZLGitRemoteService/Classes/**/*.{h,m,swift}'
  s.prefix_header_file= 'ZLGitRemoteService/Classes/ZLGitRemoteService-prefix.pch'
  s.public_header_files = ['ZLGitRemoteService/Classes/ZLGitRemoteService.h',
                           'ZLGitRemoteService/Classes/Model/**/*.h',
                           'ZLGitRemoteService/Classes/PublicUtilities/**/*.h',
                           'ZLGitRemoteService/Classes/Base/**/*.h',
                           'ZLGitRemoteService/Classes/Analyse/**/*.h',
                           'ZLGitRemoteService/Classes/PublicModule/**/*.h',
                           'ZLGitRemoteService/Classes/Tool/ZLSharedDataManager/**/*.h',
                           'ZLGitRemoteService/Classes/Network/ZLGithubHttpClient.h']
  s.vendored_libraries = 'ZLGitRemoteService/Libs/libgumbo.a'
 # s.vendored_frameworks = 'ZLGitRemoteService/Frameworks/Bugly.framework'
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "$(PODS_TARGET_SRCROOT)/ZLGitRemoteService/Libs/gumbo",
                            'LIBRARY_SEARCH_PATHS' => "$(PODS_TARGET_SRCROOT)/ZLGitRemoteService/Libs",
                            'FRAMEWORK_SEARCH_PATHS' => "$(PODS_TARGET_SRCROOT)/ZLGitRemoteService/Frameworks",
                            'DEFINES_MODULE' => 'YES'}
  s.swift_version = '5.0'
  s.static_framework = true
  
  # s.resource_bundles = {
  #   'ZLGitRemoteService' => ['ZLGitRemoteService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Umbrella'
  s.dependency 'Umbrella/Firebase'
  s.dependency 'Firebase/Analytics'
  s.dependency 'AFNetworking'
  s.dependency 'FMDB'
  s.dependency 'CocoaLumberjack'
  s.dependency 'MJExtension'
  s.dependency 'Apollo', '~> 0.48.0'
  s.dependency 'SYDCentralPivot', '~> 1.3.0'
  s.dependency 'Bugly'

end
