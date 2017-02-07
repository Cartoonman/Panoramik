#import <Foundation/Foundation.h>

/**
  This OAuth implementation is a very simple, HMAC only, utility class
  for handling the request headers necessary with almost any OAuth client.
*/

@interface BFOAuth : NSObject {
    NSString *signatureSecret;
    NSDictionary *params;
}

@property (nonatomic, retain) NSURL *requestURL;
@property (nonatomic, retain) NSString *requestMethod;
@property (nonatomic, retain) NSDictionary *requestParameters;

extern NSString *const kBFOAuthGETRequestMethod;
extern NSString *const kBFOAuthPOSTRequestMethod;
extern NSString *const kBFOAuthPUTRequestMethod;
extern NSString *const kBFOAuthDELETERequestMethod;
extern NSString *const kBFOAuthPATCHRequestMethod;

- (NSString *)signatureBase;
- (NSString *)signature;
- (NSString *)authorizationHeader;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret;

/**
  OAuth requires the UTC timestamp we send to be accurate. The user's device
  may not be, and often isn't. To work around this you should set this to the
  UTC timestamp that you get back in HTTP header from OAuth servers.
*/
extern int BFOAuthUTCTimeOffset;

@end


@interface NSString (BFOAuth)
- (NSString*)pcen;
@end

@interface NSMutableString (BFOAuth)
- (NSMutableString *)add:(NSString *)s;
- (NSMutableString *)chomp;
@end
