#import "BFOAuth.h"
#import <CommonCrypto/CommonHMAC.h>

int BFOAuthUTCTimeOffset = 0;

NSString *const kBFOAuthGETRequestMethod = @"GET";
NSString *const kBFOAuthPOSTRequestMethod = @"POST";
NSString *const kBFOAuthPUTRequestMethod = @"PUT";
NSString *const kBFOAuthDELETERequestMethod = @"DELETE";
NSString *const kBFOAuthPATCHRequestMethod = @"PATCH";

NSString *const kBFOAuthConsumerKey = @"oauth_consumer_key";
NSString *const kBFOAuthNonce       = @"oauth_nonce";
NSString *const kBFOAuthTimestamp   = @"oauth_timestamp";
NSString *const kBFOAuthVersion     = @"oauth_version";
NSString *const kBFOAuthSignatureMethod = @"oauth_signature_method";
NSString *const kBFOAuthAccessToken = @"oauth_token";
NSString *const kBFOAuthSignature   = @"oauth_signature";


#pragma mark Categories

@implementation NSString (BFOAuth)
- (id)pcen {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}
@end

@implementation NSNumber (BFOAuth)
- (id)pcen {
    // We permit NSNumbers as parameters, so we need to handle this function call
    return [self stringValue];
}
@end

@implementation NSMutableString (BFOAuth)
- (id)add:(NSString *)s {
    if ([s isKindOfClass:[NSString class]])
        [self appendString:s];
    if ([s isKindOfClass:[NSNumber class]])
        [self appendString:[(NSNumber *)s stringValue]];
    return self;
}
- (id)chomp {
    const long N = self.length - 1;
    if (N >= 0)
        [self deleteCharactersInRange:NSMakeRange(N, 1)];
    return self;
}
@end

#pragma mark OAuth C-functions

// If your input string isn't 20 characters this won't work.
static NSString* base64(const uint8_t* input) {
    static const char map[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    NSMutableData* data = [NSMutableData dataWithLength:28];
    uint8_t* out = (uint8_t*) data.mutableBytes;

    for (int i = 0; i < 20;) {
        int v  = 0;
        for (const int N = i + 3; i < N; i++) {
            v <<= 8;
            v |= 0xFF & input[i];
        }
        *out++ = map[v >> 18 & 0x3F];
        *out++ = map[v >> 12 & 0x3F];
        *out++ = map[v >> 6 & 0x3F];
        *out++ = map[v >> 0 & 0x3F];
    }
    out[-2] = map[(input[19] & 0x0F) << 2];
    out[-1] = '=';
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

static NSString* nonce() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (id)CFBridgingRelease(s);
}

static NSString* timestamp() {
    time_t t;
    time(&t);
    mktime(gmtime(&t));
    return [NSString stringWithFormat:@"%lu", t + BFOAuthUTCTimeOffset];
}

#pragma mark Implementation

@implementation BFOAuth

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret
{
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              consumerKey,  kBFOAuthConsumerKey,
              nonce(),      kBFOAuthNonce,
              timestamp(),  kBFOAuthTimestamp,
              @"1.0",       kBFOAuthVersion,
              @"HMAC-SHA1", kBFOAuthSignatureMethod,
              accessToken,  kBFOAuthAccessToken,
              // LEAVE accessToken last or you'll break XAuth attempts
              nil];
    signatureSecret = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret ?: @""];
    return self;
}

- (NSDictionary *)parametersForSignature
{
    if (self.requestParameters == nil)
        return params;
    
    NSMutableDictionary *mergedParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mergedParams addEntriesFromDictionary:self.requestParameters];
    return mergedParams;
}

- (NSString *)signatureBase
{
    NSMutableString *p3 = [NSMutableString stringWithCapacity:256];
    NSArray *keys = [[[self parametersForSignature] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        NSString *value = [[self parametersForSignature] objectForKey:key];
        [[[[p3 add:[key pcen]] add:@"="] add:[value pcen]] add:@"&"];
    }
    [p3 chomp];

    return [NSString stringWithFormat:@"%@&%@%%3A%%2F%%2F%@%@&%@",
            self.requestMethod,
            self.requestURL.scheme.lowercaseString,
            self.requestURL.host.lowercaseString.pcen,
            self.requestURL.path.pcen,
            p3.pcen];
}

- (NSString *)signature
{
    NSData *sigbase = [[self signatureBase] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [signatureSecret dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t digest[20] = {0};
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, secret.bytes, secret.length);
    CCHmacUpdate(&cx, sigbase.bytes, sigbase.length);
    CCHmacFinal(&cx, digest);

    return base64(digest);
}

- (NSString *)authorizationHeader
{
    NSMutableString *header = [NSMutableString stringWithCapacity:512];
    [header add:@"OAuth "];
    for (NSString *key in [params allKeys])
        [[[[header add:key] add:@"=\""] add:[params objectForKey:key]] add:@"\", "];
    [[[header add:[NSString stringWithFormat:@"%@=\"", kBFOAuthSignature]] add:self.signature.pcen] add:@"\""];
    
    return header;
}

@end
