#
# Be sure to run `pod lib lint DynamicWaveCollectionView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DynamicWaveCollectionView'
  s.version          = '0.9.2'
  s.summary          = 'UICollectionView with floating rows (like iMassage) + "didSelectItemAtIndexPath" wave animation'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
If You want table or collection with floating, dumping, stretching (dynamic) cells (items) like iMessage app DynamicWaveCollectionView is what you want!

DynamicWaveCollectionView is a subclass of UICollectionViewController + UICollectionViewFlowLayout with a simple API with floating rows + "didSelectItemAtIndexPath" wave animation
                       DESC

  s.homepage         = 'https://github.com/CoolCodeFactory/DynamicWaveCollectionView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitry Utmanov' => 'utm4@mail.ru' }
  s.source           = { :git => 'https://github.com/CoolCodeFactory/DynamicWaveCollectionView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DynamicWaveCollectionView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DynamicWaveCollectionView' => ['DynamicWaveCollectionView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
