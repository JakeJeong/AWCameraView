Pod::Spec.new do |s|
	s.name = 'JBCameraView'
	s.version = '0.3.0'
	s.summary = 'UIView to show the camera, take a picture, preview it, return UIImage'
	s.homepage = 'https://github.com/billinghamj/JBCameraView'
	s.license = 'MIT'
	s.author = { 'James Billingham' => 'james@billingham.net', 'Markos Charatzas' => 'markos@qnoid.com' }

	s.source = { git: 'https://github.com/billinghamj/JBCameraView.git', tag: "v#{s.version}" }

	s.requires_arc = true
	s.ios.deployment_target = '6.0'

	s.source_files = 'JBCameraView/*.{h,m}'
	s.public_header_files = 'JBCameraView/*.h'

	s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'CoreMedia', 'CoreGraphics'
end
