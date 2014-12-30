Pod::Spec.new do |s|
  s.name             = "Vokoder"
  s.version          = "1.1.1"
  s.summary          = "VOKAL's Core Data Manager"
  s.homepage         = "https://github.com/vokalinteractive/Vokoder"
  s.license          = { :type => "MIT", :file => "LICENSE"}
  s.author           = { "VOKAL Interactive" => "hello@vokalinteractive.com" }
  s.source           = { :git => "https://github.com/vokalinteractive/Vokoder.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.subspec 'Core' do |ss|
    ss.source_files = 'Pod/Classes/*.{h,m}', 'Pod/Classes/Internal'
    ss.framework    = "CoreData"
  end

  s.subspec 'DataSources' do |ss|
    ss.dependency 'Vokoder/Core'

    ss.default_subspecs = 'FetchedResults', 'PagingFetchedResults', 'Collection'

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

    ss.subspec 'Carousel' do |sss|
      sss.source_files = 'Pod/Classes/Optional Data Sources/VOKCarouselDataSource.{h,m}'
      sss.dependency 'Vokoder/DataSources/FetchedResults'
      sss.dependency 'iCarousel', '~> 1.7.3'
    end
  end

  s.source_files = 'Pod/Classes'
end
