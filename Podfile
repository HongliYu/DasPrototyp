# Podfile
platform :ios, '10.0'

def main_pods
  pod 'Firebase/Core'
  pod 'Fabric', '~> 1.8.2'
  pod 'Crashlytics', '~> 3.11.1'

  pod 'DeviceUtil', '4.0.3'

	# network service
	pod 'AFNetworking','3.2.1'

	# database
	pod 'FMDB','2.7.5'

	# output different log level with XcodeColors:https://github.com/robbiehanson/XcodeColors
	pod 'CocoaLumberjack','3.4.2'

	# hanlde .zip files
	pod 'SSZipArchive','2.1.3'

	# interactive components
	pod 'SCLAlertView-Objective-C','1.1.6'
	pod 'SVProgressHUD','2.2.5'
	pod 'SVPullToRefresh','0.4.1'
	pod 'HMSegmentedControl','1.5.5'
end

def shared_pods
  pod 'AFNetworking','3.2.1'
end

target 'DasPrototyp' do
  use_frameworks!
  main_pods
end

target 'DPTodayExtension' do
  use_frameworks!
  shared_pods
end
