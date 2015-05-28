#
# Be sure to run `pod lib lint BDUIViewUpdateQueue.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BDUIViewUpdateQueue"
  s.version          = "0.1.2"
  s.summary          = "A class helps queuing asynchronous updates of UITableView (or UICollectionView)."
  s.description      = <<-DESC
                      When using UITableView or UICollectionView, asynchronous updating of your datasource and your view can be difficult without proper queuing. Sometimes upating these views can even crash your app (NSInternalInconsistencyException dreads). 

`BDUIViewUpdateQueue` uses GCD (`dispatch_queue_t`) to lock your view to a serial queue, then execute your block in the main queue. That way datasource will always sync up with the state of your UITableView or UICollectionView. Other views will also work.

                       DESC
  s.homepage         = "https://github.com/norsez/BDUIViewUpdateQueue"

  s.license          = 'MIT'
  s.author           = { "Norsez Orankijanan" => "norsez@gmail.com" }
  s.source           = { :git => "https://github.com/norsez/BDUIViewUpdateQueue.git", :tag => s.version.to_s }


  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BDUIViewUpdateQueue' => ['Pod/Assets/*.png']
  }

end
