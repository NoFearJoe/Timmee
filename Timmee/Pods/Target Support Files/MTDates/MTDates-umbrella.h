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

#import "NSDate+MTDates.h"
#import "NSDateComponents+MTDates.h"

FOUNDATION_EXPORT double MTDatesVersionNumber;
FOUNDATION_EXPORT const unsigned char MTDatesVersionString[];

