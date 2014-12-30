//
//  VOKCoreDataManagerInternalMacros.h
//  SampleProject
//
//  Created by Isaac Greenspan on 5/21/14.
//
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


#endif
