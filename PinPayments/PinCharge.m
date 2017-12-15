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

@implementation PinMutableCharge
- (instancetype)init {
    if (self = [super init]) {
        _email = nil;
        _chargeDescription = nil;
        _amount = 0;
        _ipAddress = nil;
        _created = nil;
        _currency = nil;
        _capture = nil;
        _success = NO;
        _statusMessage = nil;
        _errorMessage = nil;
        _card = nil;
        _authorizationExpired = nil;
        _token = nil;
        _cardToken = nil;
        _customerToken = nil;
        _metadata = nil;
    }
    return self;
}
@end

NSString * const PinChargeQuerySortField_toString[] = {
    [PinChargeQuerySortFieldCreatedAt] = @"created_at",
    [PinChargeQuerySortFieldAmount] = @"amount",
    [PinChargeQuerySortFieldDescription] = @"description"
};

@implementation PinChargeQuery

+ (nullable NSDateFormatter*)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    return dateFormatter;
}

- (nullable instancetype)init {
    if ([super init]) {
        _query = nil;
        _startDate = nil;
        _endDate = nil;
        _sortField = 0;
        _direction = 0;
    }
    return self;
}

- (nonnull NSDictionary*)queryParameters {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_query) {
        dictionary[@"query"] = _query;
    }
    if (_startDate) {
        dictionary[@"start_date"] = [[PinChargeQuery dateFormatter] stringFromDate:_startDate];
    }
    if (_endDate) {
        dictionary[@"end_date"] = [[PinChargeQuery dateFormatter] stringFromDate:_endDate];
    }
    if (_sortField != 0) {
        dictionary[@"sort"] = PinChargeQuerySortField_toString[_sortField];
    }
    if (_direction != 0) {
        dictionary[@"direction"] = [NSNumber numberWithInteger:_direction];
    }
    return dictionary;
}
@end

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

+ (instancetype _Nullable)chargeFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinCharge *charge = [[PinCharge alloc] init];
    [charge jsonSetValuesForKeysWithDictionary:dictionary];
    return charge;
}

+ (void)createChargeInBackground:(nonnull PinCharge*)charge block:(nonnull PinChargeResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [charge encodeIntoDictionary];
    [manager POST: @"charges" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinCharge chargeFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchChargesInBackground:(nonnull PinChargeArrayResultBlock)block {
    [self fetchChargesInBackground:@1 block:block];
}

+ (void)fetchChargesInBackground:(nonnull NSNumber*)page block:(nonnull PinChargeArrayResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET: @"charges" parameters:@{ @"page": page } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchChargesMatchingCriteriaInBackground:(nonnull PinChargeQuery*)query block:(nonnull PinChargeArrayResultBlock)block{
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET: @"charges/search" parameters:[query queryParameters] progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchChargeDetailsInBackground:(nonnull NSString*)chargeToken block:(nonnull PinChargeResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"%@/%@", @"charges", chargeToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        PinCharge *charge = [PinCharge chargeFromDictionary: responseObject[@"response"]];
        block(charge, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

-(instancetype)initWithBlock:(nonnull PinChargeBuilderBlock)block {
    PinMutableCharge *builder = [[PinMutableCharge alloc] init];
    block(builder);
    if (self = [super init]) {
        _email = builder.email;
        _chargeDescription = builder.chargeDescription;
        _amount = builder.amount;
        _ipAddress = builder.ipAddress;
        _created = builder.created;
        _currency = builder.currency;
        _capture = builder.capture;
        _success = builder.success;
        _statusMessage = builder.statusMessage;
        _errorMessage = builder.errorMessage;
        _card = builder.card;
        _authorizationExpired = builder.authorizationExpired;
        _token = builder.token;
        _cardToken = builder.cardToken;
        _customerToken = builder.customerToken;
        _metadata = builder.metadata;
    }
    return self;
}

- (nonnull NSDictionary*)encodeIntoDictionary {
   return [self dictionaryWithValuesForKeys:[[PinCharge jsonMapping] allValues]];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PinCharge: Token=%@ Card=%@ Success=%@", self.token, self.card, self.success ? @"true" : @"false"];
}

@end
