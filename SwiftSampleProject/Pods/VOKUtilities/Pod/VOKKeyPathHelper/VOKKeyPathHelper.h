//
//  VOKKeyPathHelper.h
//  VOKUtilities
//
//  Created by Isaac Greenspan on 1/22/16.
//  Copyright (c) 2016 Vokal. All rights reserved.
//

#ifndef VOKKeyPathHelper_h
#define VOKKeyPathHelper_h

/**
 *  Helper category to define both class and instance methods that return \c instancetype so that whether \c self is an
 *  instance or a class, we can readily get an instance against which to check existence of a key.
 */
@interface NSObject (VOKKeyHelperMethodsForCompilerWarnings)

/**
 *  Helper method to get an instance from \c self in an arbitrary class method.
 *
 *  @return An instance of the receiver.
 */
+ (instancetype)vok_keyHelperMethodForCompilerWarning;

/**
 *  Helper method to get an instance from \c self in an arbitrary instance method.
 *
 *  @return An instance of the same class as the receiver.
 */
- (instancetype)vok_keyHelperMethodForCompilerWarning;

@end

/**
 *  Get a string for a key on the given object with compile-time checking that the key exists on that object.
 *
 *  @param __vok__object The object
 *  @param __vok__key    The key (as a bare symbol)
 *
 *  @return The string form of the key
 */
#define VOKKeyForObject(__vok__object, __vok__key) ({ while (NO) { (void)__vok__object.__vok__key; } @#__vok__key; })

/**
 *  Get a string for an instance key on self with compile-time checking that the key exists on instances of self.
 *
 *  @param __vok__key The key (as a bare symbol)
 *
 *  @return The string form of the key
 */
#define VOKKeyForSelf(__vok__key) VOKKeyForObject([super vok_keyHelperMethodForCompilerWarning], __vok__key)

/**
 *  Get a string for a key on an instance of the given class with compile-time checking that the key exists on instance of that class.
 *
 *  @param __vok__class The class
 *  @param __vok__key   The key (as a bare symbol)
 *
 *  @return The string form of the key
 */
#define VOKKeyForInstanceOf(__vok__class, __vok__key) ({ while (NO) { (void)((__vok__class *)nil).__vok__key; } @#__vok__key; })

/**
 *  Get a string for a key on a given class with compile-time checking that the key exists on the class (as a class method).
 *
 *  @param __vok__class The class
 *  @param __vok__key   The key (as a bare symbol)
 *
 *  @return The string form of the key
 */
#define VOKKeyForClass(__vok__class, __vok__key) ({ while (NO) { (void)[__vok__class __vok__key]; } @#__vok__key; })

/**
 *  Assemble a key path from the given keys.
 *
 *  @param ... The keys (\c NSString) from which to make the path.
 *
 *  @return The key path
 */
#define VOKPathFromKeys(...) [@[__VA_ARGS__] componentsJoinedByString:@"."]

#endif /* VOKKeyPathHelper_h */
