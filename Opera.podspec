Pod::Spec.new do |s|
  s.name             = "Opera"
  s.version          = "1.0.0"
  s.summary          = "Protocol-Oriented Network abstraction layer written in Swift."
  s.homepage         = "https://github.com/xmartlabs/Opera"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Martin Barreto' => 'martin@xmartlabs.com' }
  s.source           = { git: "https://github.com/xmartlabs/Opera.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.source_files = 'Sources/Common/**/*'
  s.ios.source_files = 'Sources/iOS/**/*'
  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'RxSwift', '~> 2.0'
  s.dependency 'RxCocoa', '~> 2.0'
  s.dependency 'WebLinking', '~> 1.0'
end
