//
//  VOKManagedObjectMapperMacros.h
//  Vokoder
//
//  Copyright © 2016 Vokal.
//

#ifndef VOKManagedObjectMapperMacros_h
#define VOKManagedObjectMapperMacros_h

#import "VOKManagedObjectMap.h"

#import <VOKUtilities/VOKKeyPathHelper.h>

/**
 *  Creates a map with the default date mapper.
 *
 *  @param inputKeyPath           The foreign key to match with the local key.
 *  @param coreDataSelectorSymbol The local selector symbol.
 *  @param klass                  The class on which the local selector symbol is defined.
 *
 *  @return A VOKManagedObjectMap
 */
#ifndef VOKMapForeignToLocalClassProperty
#   define VOKMapForeignToLocalClassProperty(inputKeyPath, klass, coreDataSelectorSymbol) \
[VOKManagedObjectMap mapWithForeignKeyPath:inputKeyPath coreDataKey:VOKKeyForInstanceOf(klass, coreDataSelectorSymbol)]
#endif

/**
 *  Creates a map with the default date mapper.
 *
 *  @param inputKeyPath           The foreign key to match with the local key.
 *  @param coreDataSelectorSymbol The local selector symbol on the class of self.
 *
 *  @return A VOKManagedObjectMap
 */
#ifndef VOKMapForeignToLocalForSelf
#   define VOKMapForeignToLocalForSelf(inputKeyPath, coreDataSelectorSymbol) \
[VOKManagedObjectMap mapWithForeignKeyPath:inputKeyPath coreDataKey:VOKKeyForSelf(coreDataSelectorSymbol)]
#endif

#endif /* VOKManagedObjectMapperMacros_h */
