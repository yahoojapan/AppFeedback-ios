Pod::Spec.new do |s|
  s.name                  = "AppFeedback"
  s.version               = "1.0.0"
  s.summary               = "You can post feedback messages and screenshots to Slack from your app!"

  s.description           = <<-DESC
                            Feature
                            - Post feedback message to Slack
                            - Show floating button for feedback
                            - Two fingers long press to show feedback dialog
                            - Take a screenshot & Record screen
                            DESC

  s.homepage              = "https://github.com/yahoojapan/AppFeedback.git"
  s.license               = "MIT"
  s.author                = "Yahoo Japan Corporation"

  s.ios.deployment_target = "9.0"
  s.platform = :ios, '9.0'

  s.source_files          = "AppFeedback/*.{h,m}"
  s.public_header_files   = 'AppFeedback/AppFeedback.h'
  s.resource_bundles      = {
    'AppFeedbackResource' => ['AppFeedback/Images.xcassets', 'AppFeedback/**/*.{xib,storyboard}']
  }

  s.requires_arc          = true
  s.source                = { :git => "https://github.com/yahoojapan/AppFeedback.git", :tag => s.version }
end
