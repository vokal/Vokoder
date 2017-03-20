Pod::Spec.new do |s|
  s.name             = "Vokoder"
  s.version          = "5.0.1"
  s.summary          = "Vokal's Core Data Manager"
  s.homepage         = "https://github.com/vokal/Vokoder"
  s.license          = { :type => "MIT", :file => "LICENSE"}
  s.author           = { "Vokal" => "ios@vokal.io" }
  s.source           = { :git => "https://github.com/vokal/Vokoder.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '3.0'
  s.requires_arc = true

  s.default_subspecs = 'Core', 'MapperMacros', 'DataSources'

  s.subspec 'Core' do |ss|
    ss.source_files = [
      'Pod/Classes/*.{h,m}',
      'Pod/Classes/Internal',
    ]
    ss.framework    = "CoreData"
    ss.dependency 'ILGDynamicObjC/ILGClasses', '~> 0.1.1'
    ss.dependency 'VOKUtilities/VOKKeyPathHelper', '~> 0.11.0'
  end

  s.subspec 'MapperMacros' do |mm|
    mm.dependency 'Vokoder/Core'
    mm.source_files = 'Pod/Classes/MapperMacros/*.{h,m}'
  end

  s.subspec 'DataSources' do |ss|
    ss.dependency 'Vokoder/Core'
    ss.ios.deployment_target = '8.0'
    ss.tvos.deployment_target = '9.0'

    ss.subspec 'FetchedResults' do |sss|
      sss.source_files = 'Pod/Classes/Optional Data Sources/VOKFetchedResultsDataSource.{h,m}'
    end

    ss.subspec 'PagingFetchedResults' do |sss|
      sss.source_files = [
        'Pod/Classes/Optional Data Sources/VOKPagingFetchedResultsDataSource.{h,m}',
        'Pod/Classes/Optional Data Sources/VOKDefaultPagingAccessory.{h,m}',
      ]
      sss.dependency 'Vokoder/DataSources/FetchedResults'
    end

    ss.subspec 'Collection' do |sss|
      sss.source_files = 'Pod/Classes/Optional Data Sources/VOKCollectionDataSource.{h,m}'
      sss.dependency 'Vokoder/DataSources/FetchedResults'
    end
  end

  s.subspec 'Swift' do |sw|
    sw.ios.deployment_target = '8.0'
    sw.tvos.deployment_target = '9.0'
    sw.watchos.deployment_target = '3.0'
    
    sw.dependency 'Vokoder/Core'
    sw.source_files = 'Pod/Classes/Swift/*.swift'
  end
end
