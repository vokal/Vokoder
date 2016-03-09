//
//  VOKCoreDataManagerInternalMacros.h
//  Vokoder
//
//  Created by Isaac Greenspan on 5/21/14.
//  Copyright © 2014 Vokal.
//

#ifndef VOKCoreDataManagerInternalMacros_h
#define VOKCoreDataManagerInternalMacros_h


#ifndef VOK_CDLog
#   ifdef DEBUG
#       define VOK_CDLog(...) NSLog(@"%s\n%@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#   else
#       define VOK_CDLog(...) do {} while (0)
#   endif
#endif

#ifndef VOK_TARGET_USES_UIKIT
    #define VOK_TARGET_USES_UIKIT (TARGET_OS_IOS | TARGET_OS_TV)
#endif

#endif
