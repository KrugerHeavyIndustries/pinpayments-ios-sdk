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
#import <PinPayments/PinRequest.h>

@implementation PinChargeError

+ (NSDictionary*)jsonMapping {
    return @{@"error": propertyKey(error),
             @"error_description": propertyKey(errorDescription),
             @"messages": propertyKey(messages),
             @"charge_token": propertyKey(chargeToken)};
}

+ (instancetype _Nullable)fromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinChargeError *error = [[PinChargeError alloc] init];
    [error jsonSetValuesForKeysWithDictionary:dictionary];
    return error;
}

@end

@implementation PinMutableCharge

+ (NSDictionary*)jsonMapping {
    return @{@"amount": propertyKey(amount),
             @"currency": propertyKey(currency),
             @"description": propertyKey(chargeDescription),
             @"email": propertyKey(email),
             @"ip_address":propertyKey(ipAddress),
             @"card": propertyKey(card)};
}

- (instancetype)init {
    if (self = [super init]) {
        _amount = 0;
        _chargeDescription = nil;
        _email = nil;
        _ipAddress = nil;
        _card = [[PinMutableCard alloc] init];
        _metadata = nil;
    }
    return self;
}

- (id)valueForKey:(NSString *)key {
    NSString* nativeKey = [[PinMutableCharge jsonMapping] valueForKey:key];
    id val = [super valueForKey:nativeKey];
    if ([val isKindOfClass:[PinMutableCard class]]) {
        return [self.card dictionaryWithValuesForKeys:[[PinMutableCard jsonMapping] allKeys]];
    }
    return val;
}

- (nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinMutableCharge jsonMapping] allKeys]];
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

+ (void)createChargeInBackground:(nonnull PinMutableCharge*)charge block:(nonnull PinChargeResultBlock)block {
    NSDictionary* parameters = [charge encodeIntoDictionary];
    [PinRequest POST:@"charges" contentType:@"application/json" parameters:parameters success:^(id _Nullable responseObject) {
        block([PinCharge chargeFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSError *error) {
        if (error.domain == PinRequestFailingURLResponseErrorDomain) {
            NSError *jsonError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:error.userInfo[PinRequestFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:&jsonError];
            block(nil, [PinChargeError fromDictionary:jsonObject]);
        } else {
            block(nil, [PinChargeError fromDictionary:@{ @"error": @"system_error", @"error_description": error.localizedDescription}]);
        }
    }];
}

+ (void)fetchChargesInBackground:(nonnull PinChargeArrayResultBlock)block {
    [self fetchChargesInBackground:@1 block:block];
}

+ (void)fetchChargesInBackground:(nonnull NSNumber*)page block:(nonnull PinChargeArrayResultBlock)block {
    [PinRequest GET:@"charges" parameters:@{ @"page": page } success:^(id _Nullable responseObject) {
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchChargesMatchingCriteriaInBackground:(nonnull PinChargeQuery*)query block:(nonnull PinChargeArrayResultBlock)block{
    [PinRequest GET:@"charges/search" parameters:[query queryParameters] success:^(id _Nullable responseObject){
        NSMutableArray *charges = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        
        for (NSDictionary *c in response) {
            [charges addObject:[PinCharge chargeFromDictionary:c]];
        }
        block(charges, nil);
    } failure:^(NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchChargeDetailsInBackground:(nonnull NSString*)chargeToken block:(nonnull PinChargeResultBlock)block {
    [PinRequest GET:[NSString stringWithFormat:@"%@/%@", @"charges", chargeToken] parameters:nil success:^(id _Nullable responseObject){
        PinCharge *charge = [PinCharge chargeFromDictionary: responseObject[@"response"]];
        block(charge, nil);
    } failure:^(NSError *error) {
        block(nil, error);
    }];
}

- (nonnull NSDictionary*)encodeIntoDictionary {
   return [self dictionaryWithValuesForKeys:[[PinCharge jsonMapping] allValues]];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PinCharge: Token=%@ Card=%@ Success=%@", self.token, self.card, self.success ? @"true" : @"false"];
}

@end
