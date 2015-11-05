//
//  ILGClasses.m
//  Pods
//
//  Created by Isaac Greenspan on 6/22/15.
//
//

#import "ILGClasses.h"

#import <objc/runtime.h>

@implementation ILGClasses

+ (NSSet *)classesPassingTest:(ILGClassesClassTestBlock)test
{
    
    int numClasses;
    Class *classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    if (!numClasses) {
        return [NSSet set];
    }
    
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    if (!test) {
        NSSet *result = [NSSet setWithObjects:classes count:numClasses];
        free(classes);
        return result;
    }
    
    NSMutableSet *passingClasses = [NSMutableSet set];
    for (int index = 0; index < numClasses; index++) {
        Class class = classes[index];
        if (test(class)) {
            [passingClasses addObject:class];
        }
    }
    free(classes);
    return [passingClasses copy];
}

+ (NSSet *)subclassesOfClass:(Class)superclass
{
    return [self classesPassingTest:^BOOL(Class class) {
        // Start with the given class...
        Class workingClass = class;
        // ... and walk up the superclass chain until we get Nil or the superclass we're looking for.
        do {
            workingClass = class_getSuperclass(workingClass);
        } while (workingClass && workingClass != superclass);
        
        // If we got Nil, we went all the way up and didn't find the superclass we were looking for,
        // so the given class doesn't inherit from the target superclass.
        if (!workingClass) {
            return NO;
        }
        
        // Otherwise, the given class inherits from the target superclass.
        return YES;
    }];
}

+ (NSSet *)classesConformingToProtocol:(Protocol *)protocol
{
    return [self classesPassingTest:^BOOL(Class class) {
        return class_conformsToProtocol(class, protocol);
    }];
}

@end
