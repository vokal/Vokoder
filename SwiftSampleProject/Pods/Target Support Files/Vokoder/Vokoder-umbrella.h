#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSManagedObject+VOKManagedObjectAdditions.h"
#import "VOKCoreDataCollectionTypes.h"
#import "VOKCoreDataManager.h"
#import "VOKManagedObjectMap.h"
#import "VOKManagedObjectMapper.h"
#import "VOKMappableModel.h"
#import "VOKNullabilityFeatures.h"
#import "Vokoder.h"
#import "VOKCoreDataManagerInternalMacros.h"
#import "VOKCollectionDataSource.h"
#import "VOKFetchedResultsDataSource.h"
#import "VOKPagingFetchedResultsDataSource.h"
#import "VOKDefaultPagingAccessory.h"

FOUNDATION_EXPORT double VokoderVersionNumber;
FOUNDATION_EXPORT const unsigned char VokoderVersionString[];

