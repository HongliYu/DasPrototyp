# Podfile
platform :ios, '9.0'

def main_pods
  pod 'Masonry','1.1.0'
  
	# network service
	pod 'AFNetworking','3.2.0'

	# database
	pod 'FMDB','2.7.2'

	# output different log level with XcodeColors:https://github.com/robbiehanson/XcodeColors
	pod 'CocoaLumberjack','3.4.2'

	# hanlde .zip files
	pod 'SSZipArchive','2.1.1'

	# interactive components
	pod 'SCLAlertView-Objective-C','1.1.5'
	pod 'SVProgressHUD','2.2.5'
	pod 'SVPullToRefresh','0.4.1'
	pod 'HMSegmentedControl','1.5.4'
	pod 'ASValueTrackingSlider','0.12.1'
end

def shared_pods
  pod 'AFNetworking','3.2.0'
  pod 'Masonry','1.1.0'
end

target 'DasPrototyp' do
  main_pods
end

target 'DPTodayExtension' do
  shared_pods
end
