Pod::Spec.new do |s|
  s.name             = "OperaSwift"
  s.version          = "3.0.1-beta.0"
  s.summary          = "Protocol-Oriented Network abstraction layer written in Swift 4."
  s.homepage         = "https://github.com/xmartlabs/Opera"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Martin Barreto' => 'martin@xmartlabs.com' }
  s.source           = { git: "https://github.com/xmartlabs/Opera.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.2'
  s.watchos.deployment_target = '2.2'
  s.requires_arc = true
  s.source_files = 'Sources/Common/**/*.swift'
  s.ios.source_files = 'Sources/iOS/**/*.swift'
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'RxSwift', '4.0.0-beta.0'
  s.dependency 'RxCocoa', '4.0.0-beta.0'
end
