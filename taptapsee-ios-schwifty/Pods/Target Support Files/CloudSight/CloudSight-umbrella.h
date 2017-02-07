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

#import "CloudSight.h"
#import "CloudSightConnection.h"
#import "CloudSightDelete.h"
#import "CloudSightImageRequest.h"
#import "CloudSightImageRequestDelegate.h"
#import "CloudSightImageResponse.h"
#import "CloudSightQuery.h"
#import "CloudSightQueryDelegate.h"
#import "CloudSightUploadProgressDelegate.h"

FOUNDATION_EXPORT double CloudSightVersionNumber;
FOUNDATION_EXPORT const unsigned char CloudSightVersionString[];

