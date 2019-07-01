Pod::Spec.new do |s|

  s.name         = "PRCAdminDistricts"
  s.version      = "1.0.5"
  s.summary      = "Administrative districts of the People's Republic of China"
  s.description  = <<-DESC
                   Administrative districts of the People's Republic of China.
                   DESC
  s.homepage     = "https://github.com/xinyzhao/PRCAdminDistricts"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "xinyzhao" => "xinyzhao@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/xinyzhao/PRCAdminDistricts.git", :tag => "#{s.version}" }
  s.requires_arc = true

  s.frameworks = "Foundation"

  s.source_files  = "Class/*.{h,m}"
  s.public_header_files = "Class/*.h"

end
