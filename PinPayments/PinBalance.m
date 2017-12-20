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

#import <PinPayments/PinPayments.h>
#import <PinPayments/NSObject+Json.h>

#include <AFNetworking/AFNetworking.h>

@implementation PinBalanceFragment

+ (NSDictionary*)jsonMapping {
    return @{ @"amount": propertyKey(amount),
              @"currency": propertyKey(currency) };
}

+ (instancetype _Nullable)fragmentFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinBalanceFragment *fragment = [[PinBalanceFragment alloc] init];
    [fragment jsonSetValuesForKeysWithDictionary:dictionary];
    return fragment;
}

@end

@implementation PinBalance

+ (NSDictionary*)jsonMapping {
    return @{ @"available": propertyKey(available),
              @"pending": propertyKey(pending) };
}

+ (instancetype _Nullable)balanceFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinBalance *balance = [[PinBalance alloc] init];
    [balance jsonSetValuesForKeysWithDictionary:dictionary];
    return balance;
}

+ (void)fetchBalanceInBackground:(nonnull PinBalanceBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:@"balance" parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        NSMutableArray<PinBalanceFragment*> *available = @[].mutableCopy;
        for (NSDictionary* avail in responseObject[@"response"][@"available"]) {
            [available addObject:[PinBalanceFragment fragmentFromDictionary:avail]];
        }
        NSMutableArray<PinBalanceFragment*> *pending = @[].mutableCopy;
        for (NSDictionary* pend in responseObject[@"response"][@"pending"]) {
            [pending addObject:[PinBalanceFragment fragmentFromDictionary:pend]];
        }
        block([[PinBalance alloc] initWithArrays:available pending:pending], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

- (nullable instancetype)initWithArrays:(NSArray<PinBalanceFragment*>*)available pending:(NSArray<PinBalanceFragment*>*)pending {
    if ([super init]) {
        _available = available;
        _pending = pending;
    }
    return self;
}
@end
