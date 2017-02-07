//
//  CloudSightQuery.h
//  CloudSight API
//  Copyright (c) 2012-2015 CamFind Inc. (http://cloudsightapi.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CloudSightImageRequestDelegate.h"
#import "CloudSightQueryDelegate.h"

static const int kTPQueryCancelledError = 9030;

@class CloudSightImageRequest;
@class CloudSightImageResponse;
@class CloudSightDelete;

@interface CloudSightQuery : NSObject <CloudSightImageRequestDelegate>

@property (nonatomic, retain) CloudSightImageRequest *request;
@property (nonatomic, retain) CloudSightImageResponse *response;
@property (nonatomic, retain) CloudSightDelete *destroy;
@property (nonatomic, weak) id <CloudSightQueryDelegate> queryDelegate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *skipReason;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *remoteUrl;

- (id)initWithImage:(NSData *)image atLocation:(CGPoint)location withDelegate:(id)delegate atPlacemark:(CLLocation *)placemark withDeviceId:(NSString *)deviceId;
- (void)cancelAndDestroy;
- (void)stop;
- (void)start;
- (NSString *)name;

@end
