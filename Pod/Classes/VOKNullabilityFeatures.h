//
//  VOKNullabilityFeatures.h
//  Pods
//
//  Created by Carl Hill-Popper on 10/23/15.
//
//  Copyright © 2015 Vokal.
//

#ifndef VOKNullabilityFeatures_h
#define VOKNullabilityFeatures_h

//hide nullability qualifiers if they're not supported
#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define __nullable
#endif

#endif /* VOKNullabilityFeatures_h */
