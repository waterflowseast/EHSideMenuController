Pod::Spec.new do |s|
  s.name             = 'EHSideMenuController'
  s.version          = '1.0.0'
  s.summary          = 'a side menu controller.'
  s.homepage         = 'https://github.com/waterflowseast/EHSideMenuController'
  s.screenshots     = 'https://github.com/waterflowseast/EHSideMenuController/raw/master/screenshots/1.png', 'https://github.com/waterflowseast/EHSideMenuController/raw/master/screenshots/2.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eric Huang' => 'WaterFlowsEast@gmail.com' }
  s.source           = { :git => 'https://github.com/waterflowseast/EHSideMenuController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'EHSideMenuController/Classes/**/*'
end
