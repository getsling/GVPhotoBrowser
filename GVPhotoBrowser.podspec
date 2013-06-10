Pod::Spec.new do |s|
  s.name         = "GVPhotoBrowser"
  s.version      = "0.0.1"
  s.summary      = "A reusable photo browser for iOS using the datasource and delegate patterns."
  s.homepage     = "https://github.com/gangverk/GVPhotoBrowser"
  s.license      = 'MIT'
  s.author       = { "Kevin Renskers" => "info@mixedcase.nl" }
  s.source       = { :git => "https://github.com/gangverk/GVPhotoBrowser.git", :tag => s.version.to_s }
  s.ios.deployment_target = '4.0'
  s.osx.deployment_target = '10.6'
  s.source_files = 'GVPhotoBrowser/*.{h,m}'
  s.requires_arc = true
end
