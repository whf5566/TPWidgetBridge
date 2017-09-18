Pod::Spec.new do |s|
  s.name                  = 'TPWidgetBridge'
  s.version               = '1.0.1'
  s.homepage              = 'https://github.com/whf5566/TPWidgetBridge'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'whf5566' => 'whf5566@gmail.com' }
  s.social_media_url      = 'https://www.wellphone.me'
  s.platform              = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source                = { :git => 'https://github.com/whf5566/TPWidgetBridge.git', :tag => 'v1.0.1' }
  s.source_files          = 'TPWidgetBridge/TPWidgetBridge'
  s.public_header_files   = 'TPWidgetBridge/TPWidgetBridge/*.{h}'
  s.requires_arc          = true
  s.summary               = 'TPWidgetBridge creates a bridge between an iOS extension and its containing application.'
  s.description  = <<-DESC
	  # TPWidgetBridge
	  TPWidgetBridge creates a bridge between an iOS extension and its containing application.The TPWidgetBridge supports CFNotificationCenter Darwin Notifications in an effort to support realtime change notifications.
	  DESC
end