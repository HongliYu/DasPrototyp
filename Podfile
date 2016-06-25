# Podfile
platform :ios, '7.0'

def main_pods
  pod 'Masonry','~>1.0.0'
  
	# network service
	pod 'AFNetworking','~>3.1.0'

	# database
	pod 'FMDB','~>2.5'

	# output different log level with XcodeColors:https://github.com/robbiehanson/XcodeColors
	pod 'CocoaLumberjack','~>2.2.0'

	# hanlde .zip files
	pod 'SSZipArchive','~>1.2.0'

	# interactive components
	pod 'SCLAlertView-Objective-C','1.0.2'
	pod 'SVProgressHUD','~> 2.0.3'
	pod 'SVPullToRefresh','~>0.4.1'
	pod 'HMSegmentedControl','~> 1.5.2'
	pod 'ASValueTrackingSlider','~>0.11.2'
end

def shared_pods
  pod 'AFNetworking','~>3.1.0'
  pod 'Masonry','~>1.0.0'
end

target 'DasPrototyp' do
  main_pods
end

target 'DPTodayExtension' do
  shared_pods
end