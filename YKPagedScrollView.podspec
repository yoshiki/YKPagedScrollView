Pod::Spec.new do |s|
  s.name     = 'YKPagedScrollView'
  s.version  = '1.3.11'
  s.license  = 'MIT'
  s.summary  = 'A paged scroll view which has interface like UITableView'
  s.homepage = 'https://github.com/yoshiki/YKPagedScrollView'
  s.authors  = { 'Yoshiki Kurihara' => 'clouder@gmail.com' }
  s.source   = { :git => 'https://github.com/yoshiki/YKPagedScrollView.git', :tag => "1.3.11" }
  s.requires_arc = true
  s.source_files = 'YKPagedScrollView/*.{h,m}'
  s.ios.deployment_target = '4.3'
  s.platform = :ios
end
