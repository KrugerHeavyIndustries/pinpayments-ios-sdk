// __  __ ______ _______ _______ _______ ______
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

#import <AFNetworking/AFNetworking.h>
#import "PinCharge.h"
#import "PinClient.h"
#import "NSObject+Json.h"

@implementation PinCharge

+ (NSDictionary*)jsonMapping {
    return @{@"token": propertyKey(token),
             @"success": propertyKey(success),
             @"amount": propertyKey(amount),
             @"currency": propertyKey(currency),
             @"description": propertyKey(chargeDescription),
             @"email": propertyKey(email),
             @"ip_address":propertyKey(ipAddress),
             @"created_at": propertyKey(created),
             @"status_message": propertyKey(statusMessage),
             @"error_message": propertyKey(errorMessage),
             @"card": propertyKey(card)};
}

+ (instancetype)chargeFromDictionary:(NSDictionary *)dictionary  {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinCharge *charge = [[PinCharge alloc] init];
    [charge jsonSetValuesForKeysWithDictionary: dictionary];
    return charge;
}

+ (void)createChargeInBackground:(nonnull PinCharge*)charge block:(nullable PinChargeResultBlock)block {
    PinClientConfiguration* configuration = [PinClient currentConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: configuration.server]];
    [manager POST: @"charges" parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinCharge chargeFromDictionary:responseObject[@"response"]], nil);
        NSLog(@"Charges: %@", charge);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
        NSLog(@"Error: %@", error);
    }];
}

+ (void)fetchChargesInBackground {
    [self fetchChargesInBackground: nil];
}

+ (void)fetchChargesInBackground:(nullable NSNumber*)page {
    PinClientConfiguration* configuration = [PinClient currentConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: configuration.server]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:configuration.secretKey password: @""];
    [manager GET: @"charges" parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        
        NSLog(@"Charges: %@", charges);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchChargesMatchingCriteriaInBackground {
}

- (void)fetchChargeDetailsInBackground:(NSString*)chargeToken {
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PinCharge: Token=%@ Card=%@ Success=%@", self.token, self.card, self.success ? @"true" : @"false"];
}

@end
