//
//  VOKManagedObjectMapperMacros.h
//  Vokoder
//
//  Copyright © 2016 Vokal.
//

#ifndef VOKManagedObjectMapperMacros_h
#define VOKManagedObjectMapperMacros_h

#import "VOKManagedObjectMap.h"

#import <VOKKeyPathHelper.h>

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


////////////////////////// DEPRECATED MACROS //////////////////////////

/**
 *  Generate a string from a selector symbol.
 *
 *  @param selectorSymbol The selector symbol.
 *
 *  @return An NSString
 */
#ifndef VOK_CDSELECTOR
#   ifdef DEBUG
#       define VOK_CDSELECTOR(selectorSymbol) _Pragma ("GCC warning \"'VOK_CDSELECTOR' macro is deprecated and will be removed in version 3.0. Use the appropriate macro from VOKUtilities/VOKKeyPathHelper instead.\"") NSStringFromSelector(@selector(selectorSymbol))
#   else
#       define VOK_CDSELECTOR(selectorSymbol) _Pragma ("GCC warning \"'VOK_CDSELECTOR' macro is deprecated and will be removed in version 3.0. Use the appropriate macro from VOKUtilities/VOKKeyPathHelper instead.\"") @#selectorSymbol //in release builds @#selectorSymbol becomes @"{selectorSymbol}"
#   endif
#endif

/**
 *  Creates a map with the default date mapper.
 *
 *  @param inputKeyPath           The foreign key to match with the local key.
 *  @param coreDataSelectorSymbol The local selector symbol.
 *
 *  @return A VOKManagedObjectMap
 */
#ifndef VOK_MAP_FOREIGN_TO_LOCAL
#   define VOK_MAP_FOREIGN_TO_LOCAL(inputKeyPath, coreDataSelectorSymbol) \
_Pragma ("GCC warning \"'VOK_MAP_FOREIGN_TO_LOCAL' macro is deprecated and will be removed in version 3.0. Use VOKMapForeignToLocalForClass or VOKMapForeignToLocalForSelf instead.\"") \
[VOKManagedObjectMap mapWithForeignKeyPath:inputKeyPath coreDataKey:VOK_CDSELECTOR(coreDataSelectorSymbol)]
#endif

#endif /* VOKManagedObjectMapperMacros_h */
