

Pod::Spec.new do |s|

  s.name         = "JWNetworkings"
  s.version      = "0.1.8"
  s.summary      = "JWNetworkings--自用的一款网络库，基于AFNetworking的二次封装"

  #主页
  s.homepage     = "https://github.com/junwangInChina/JWNetworking"
  #证书申明
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  #作者
  s.author       = { "wangjun" => "578382239@qq.com" }
  #支持版本
  s.platform     = :ios, "9.1"
  #版本地址
  s.source       = { :git => "https://github.com/junwangInChina/JWNetworking.git", :tag => s.version }

  #库文件路径（相对于.podspec文件的路径）
  s.source_files  = "JWNetworking/JWNetworking/JWNetworking/**/*.{h,m}"
  #是否支持arc
  s.requires_arc = true
  #外用库
  s.dependency 'AFNetworking' 
  s.dependency 'JWTrace'

end
