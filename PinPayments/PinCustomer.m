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

#import <AFNetworking/AFNetworking.h>

@implementation PinCustomer

+ (NSDictionary*)jsonMapping {
    return @{@"token": propertyKey(token),
             @"email": propertyKey(email),
             @"created_at": propertyKey(createdAt),
             @"card_token": propertyKey(cardToken),
             @"card": propertyKey(card)};
}

+ (instancetype _Nullable)customerFromDictionary:(nonnull NSDictionary *)dictionary  {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinCustomer *customer = [[PinCustomer alloc] init];
    [customer jsonSetValuesForKeysWithDictionary:dictionary];
    return customer;
}

+ (void)createCustomerInBackground:(nonnull PinCustomer*)customer block:(nonnull PinCustomerResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [customer encodeIntoDictionary];
    [manager POST:@"customers" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinCustomer customerFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchCustomersInBackground:(nonnull PinCustomerArrayResultBlock)block {
    [self fetchCustomersInBackground:@1 block:block];
}

+ (void)fetchCustomersInBackground:(nonnull NSNumber*)page block:(nonnull PinCustomerArrayResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:@"customers" parameters:@{ @"page": page } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [charges addObject:[PinCustomer customerFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchCustomerDetailsInBackground:(nonnull NSString*)customerToken block:(nonnull PinCustomerResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"%@/%@", @"customers", customerToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        PinCustomer *customer = [PinCustomer customerFromDictionary: responseObject[@"response"]];
        block(customer, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)updateCustomerDetailsInBackground:(nonnull NSString*)customerToken block:(nonnull PinCustomerResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    [manager PUT:[NSString stringWithFormat:@"customers/%@", customerToken] parameters:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinCustomer customerFromDictionary: responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)deleteCustomerInBackground:(nonnull NSString*)customerToken block:(nonnull PinCustomerConfirmationBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager DELETE:[NSString stringWithFormat:@"customers/%@", customerToken] parameters:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block(YES, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(FALSE, error);
    }];
}

+ (void)fetchCustomerChargesInBackground:(nonnull NSString*)customerToken block:(nonnull PinCustomerChargesResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"customers/%@/charges", customerToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        NSMutableArray<PinCharge*> *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchCustomerCardsInBackground:(nonnull NSString*)customerToken block:(nonnull PinCustomerCardsResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"customers/%@/cards", customerToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        NSMutableArray<PinCard*> *cards = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [cards addObject:[PinCard cardFromDictionary:c]];
        }
        block(cards, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

- (nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinCustomer jsonMapping] allValues]];
}

@end
