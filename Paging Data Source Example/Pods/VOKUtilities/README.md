# VOKUtilities

[![CI Status](https://travis-ci.org/vokal/VOKUtilities.svg?branch=master)](https://travis-ci.org/vokal/VOKUtilities)
[![Version](https://img.shields.io/cocoapods/v/VOKUtilities.svg?style=flat)](http://cocoadocs.org/docsets/VOKUtilities)
[![License](https://img.shields.io/cocoapods/l/VOKUtilities.svg?style=flat)](http://cocoadocs.org/docsets/VOKUtilities)
[![Platform](https://img.shields.io/cocoapods/p/VOKUtilities.svg?style=flat)](http://cocoadocs.org/docsets/VOKUtilities)

Assorted category and utility classes for iDevelopment.  [MIT License](LICENSE)

VOKUtilities requires Xcode 7 or higher.

All parts of this are available for iOS. Some subspecs are available on OS X and tvOS platforms.  See the [Podspec](VOKUtilities.podspec) for specifics.

## NSCalendar+VOKAL
This category on `NSCalendar` adds a convenience method to get the most recent weekday before a given `NSDate`.

## NSString+VOKValidation
This category on `NSString` adds methods to test:

- The structural validity of credit card numbers 
- The format validity of credit card CVV codes
- A string against an arbitrary regular expression 

There are also several methods to test whether a string is an email address. It should be noted that **the only 100% reliable way to validate an email address is to send an email to it and verify receipt of that email**. 

[isemail.info](http://isemail.info/) and its [source code](https://github.com/dominicsayers/isemail) are where we've gotten the test cases we use to check the accuracy of these validators. The validation methods, in order from most likely to least likely to accept a valid email address, test: 

- Superficially, if a string could be an email address by testing for the presence of an `@`: 
	- Rejects none of the valid-email test cases.
	- Allows a large number of invalid email addresses.
- A string against the W3C's [example email validation regex](http://www.w3.org/TR/html-markup/input.email.html): 
	- Rejects only deprecated or obvious edge-case emails. 	
	- Allows only a few invalid email addresses.

## NSPredicate+VOKAL
This category on `NSPredicate` adds convenience methods for some commonly constructed predicates: 
- value for key path. Shorthand for predicate format: `@K == %@`
- key path in a collection. Shorthand for predicate format: `@K IN %@`

## UIColor+VOKAL
This category on `UIColor` adds convenience creation methods to create colors based on their hex representations, both as integers (`0xA4C53F`) and as strings (`@"A4C53F"`), and an instance method to get the hex-string representation of a color.  The methods that generate `UIColor` objects from strings are particularly flexible, ignoring leading/trailing non-hexadecimal characters (such as leading `#`) and allowing various shorthands:
- `X` for `XXXXXX`
- `XY` for `XYXYXY`
- `XYZ` for `XXYYZZ`

## VOKIBHelpers
This header file is for exposing existing framework properties to interface builder through `IBInspectable`. To expose a property, add the relevant class extension declaration if needed. Then, copy and paste the property declaration from the existing framework header file. Finally, add `IBInspectable` before the property's class name. Interface builder should now display the exposed property in the attributes inspector.

## UIView+VOKDebug
This category on UIView adds a couple of useful debugging helpers:

- `vok_addDebugBorderOfColor:` adds a simple border to a given view, but only when debugging. This is helpful if you don't want to use [Chisel](https://github.com/facebook/chisel) to turn the border on every time your run. 
- `vok_addGestureRecognizerWithTestFinger:` adds a little red circle that follows the given gesture recognizer's `locationInView` of the receiver whenever `XCTestCase` is actually viable. This allows you to see where touches land in UIViews without having to add this handling to every single view. 

## UIView+VOKCircle

This category makes it very easy to crop a square view into a circle - note that this also sets `clipsToBounds` so that it will work on subclasses like `UIImageView` that normally would overflow their bounds. 

## VOKEmailHelper

This helper class provides a single method which can be called to send a basic email, and helpers to deal with the fact that Apple totally screwed up mail in the Simulator.

## UIViewController+VOKKeyboardHelper

This class adds handling for the simplest cases of showing/hiding the keyboard when the first subview of a `UIViewController`'s view is either a `UIScrollview` or a subclass of a `UIScrollview` like a `UITableView`. 

## NSNumberFormatter+VOKAL

Collection of helpers for `NSNumberFormatter`. Presently includes: 

- A singleton currency formatter which uses the user's auto-updating current locale. 

## VOKAlertHelper

A helper class with a single method, `showAlertFromViewController:withTitle:message:buttons:` for presenting an alert in the appropriate fashion both pre- and post-iOS 8. Takes an array of `VOKAlertActions` which have a title and action block and correspond to buttons.

## VOKKeyPathHelper

Macros to help with keys and key paths with compile-time checking.
