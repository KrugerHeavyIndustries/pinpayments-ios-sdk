//  __  __ ______ _______ _______ _______ ______
// |  |/  |   __ \   |   |     __|    ___|   __ \
// |     <|      <   |   |    |  |    ___|      <
// |__|\__|___|__|_______|_______|_______|___|__|
//        H E A V Y  I N D U S T R I E S
//
// Copyright (C) 2017 Kruger Heavy Industries
// http://www.krugerheavyindustries.com
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

#import "PinRequest.h"
#import "PinClient.h"
#import "PinDefaultAuthorizer.h"

NSString const *PinRequestFailingURLResponseErrorDomain = @"com.pinpayments.response.error";
NSString const *PinRequestFailingURLResponseDataErrorKey = @"com.pinpayments.response.error.data";

@interface AllowSelfSignedCertificate : NSObject
@end

@interface AllowSelfSignedCertificate ()<NSURLSessionDelegate>
@end

@implementation AllowSelfSignedCertificate

- (void) URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}
@end

@interface PinRequest()

+(id)authorizer;

@end

@implementation PinRequest

+(id)authorizer {
    static id authorizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class authorizerClass = NSClassFromString(@"PinAuthorizer");
        if (!authorizerClass) {
            authorizerClass = [PinDefaultAuthorizer class];
        }
        authorizer = [authorizerClass new];
    });
    return authorizer;
}

+ (void)perform:(NSString*)method resource:(NSString*)resource contentType:(NSString*)contentType parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {

    PinClientConfiguration* configuration = [PinClient currentConfiguration];
    
    id<NSURLSessionDelegate> sessionDelegate = configuration.insecure ? [AllowSelfSignedCertificate new] : nil;

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:sessionDelegate delegateQueue:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:resource relativeToURL:configuration.baseURL]];
    request.HTTPMethod = method;
    [[PinRequest authorizer] makeAuthorization:request];

    if (contentType) {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        if ([contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame) {
            if (parameters) {
                [request setHTTPBody: [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil]];
            }
        }
    }

    __block NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (!(200 <= httpResponse.statusCode && httpResponse.statusCode <= 300) && [response URL]) {
                NSError *error = [NSError errorWithDomain:PinRequestFailingURLResponseErrorDomain code:NSURLErrorBadServerResponse userInfo:@{ PinRequestFailingURLResponseDataErrorKey: data }];
                failure(error);
            } else {
                if (data.length > 0) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (json) {
                        success(json);
                    } else {
                        success(nil);
                    }
                } else {
                    success(nil);
                }
            }
        } else if (error) {
            failure(error);
        }
    }];
    
    [task resume];
}

+ (void)GET:(NSString*)resource parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"GET" resource:resource contentType:nil parameters:parameters success:success failure:failure];
}

+ (void)GET:(NSString*)resource contentType:(NSString*)contentType parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"GET" resource:resource contentType:contentType parameters:parameters  success:success failure:failure];
}

+ (void)POST:(NSString*)resource parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"POST" resource:resource contentType:nil parameters:parameters success:success failure:failure];
}

+ (void)POST:(NSString*)resource contentType:(NSString*)contentType parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"POST" resource:resource contentType:contentType parameters:parameters success:success failure:failure];
}

+ (void)DELETE:(NSString*)resource parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"DELETE" resource:resource contentType:nil parameters:parameters success:success failure:failure];
}

+ (void)PUT:(NSString*)resource contentType:(NSString*)contentType parameters:(NSDictionary*)parameters success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull))failure {
    [PinRequest perform:@"PUT" resource:resource contentType:contentType parameters:parameters success:success failure:failure];
}

@end
