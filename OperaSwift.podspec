Pod::Spec.new do |s|
  s.name             = "OperaSwift"
  s.version          = "1.0"
  s.summary          = "Protocol-Oriented Network abstraction layer written in Swift 3."
  s.homepage         = "https://github.com/xmartlabs/Opera"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Martin Barreto' => 'martin@xmartlabs.com' }
  s.source           = { git: "https://github.com/xmartlabs/Opera.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '9.0'
  # s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '9.0'
  # s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.source_files = 'Sources/Common/**/*'
  s.ios.source_files = 'Sources/iOS/**/*'
  s.dependency 'Alamofire', '~> 4.4.0'
  s.dependency 'RxSwift', '~> 3.1.0'
  s.dependency 'RxCocoa', '~> 3.1.0'
end
