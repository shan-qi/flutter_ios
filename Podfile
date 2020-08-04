# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
#添加如下两行代码，路径修改为我们的fluter module的路径
flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
target 'flutter_ios' do
  
  pod 'FDFullscreenPopGesture', '~> 1.1'
#  # Comment the next line if you don't want to use dynamic frameworks
##  use_frameworks!
#  # Pods for flutter_ios
install_all_flutter_pods(flutter_application_path)
end
