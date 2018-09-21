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

#import <Foundation/Foundation.h>

@class PinCard;
@class PinMutableCard;
@class PinChargeQuery;

@interface PinChargeError : NSObject
@property (nullable, nonatomic, strong) NSString *error;
@property (nullable, nonatomic, strong) NSString *errorDescription;
@property (nullable, nonatomic, strong) NSArray *messages;
@property (nullable, nonatomic, strong) NSString *chargeToken;

+ (instancetype _Nullable)fromDictionary:(nonnull NSDictionary *)dictionary;

@end

@interface PinMutableCharge : NSObject
@property (nonatomic, assign) NSInteger amount;
@property (nullable, nonatomic, strong) NSString *currency;
@property (nullable, nonatomic, strong) NSString *chargeDescription;
@property (nullable, nonatomic, strong) NSString *email;
@property (nullable, nonatomic, strong) NSString *ipAddress;
@property (nullable, nonatomic, strong) PinMutableCard *card;
@property (nullable, nonatomic, strong) NSDictionary *metadata;
@end

@interface PinCharge : NSObject

typedef void (^PinChargeBuilderBlock)(PinMutableCharge * _Nonnull builder);
typedef void (^PinChargeResultBlock)(PinCharge * _Nullable charge, PinChargeError* _Nullable error);
typedef void (^PinChargeArrayResultBlock)(NSArray<PinCharge*> *_Nullable charges, NSError *_Nullable error);

@property (readonly, nullable, nonatomic, strong) NSString *email;
@property (readonly, nullable, nonatomic, strong) NSString *chargeDescription;
@property (readonly, nonatomic, assign) NSInteger amount;
@property (readonly, nullable, nonatomic, strong) NSString *ipAddress;
@property (readonly, nullable, nonatomic, strong) NSDate *created;
@property (readonly, nullable, nonatomic, strong) NSString *currency;
@property (readonly, nonatomic, assign) BOOL capture;
@property (readonly, nonatomic, assign) BOOL success;
@property (readonly, nullable, nonatomic, strong) NSString *statusMessage;
@property (readonly, nullable, nonatomic, strong) NSString *errorMessage;
@property (readonly, nullable, nonatomic, strong) PinCard *card;
@property (readonly, nonatomic, assign) BOOL authorizationExpired;
@property (readonly, nullable, nonatomic, strong) NSString *token;
@property (readonly, nullable, nonatomic, strong) NSString *cardToken;
@property (readonly, nullable, nonatomic, strong) NSString *customerToken;
@property (readonly, nullable, nonatomic, strong) NSDictionary *metadata;

+ (instancetype _Nullable)chargeFromDictionary:(nonnull NSDictionary *)dictionary;

+ (void)createChargeInBackground:(nonnull PinMutableCharge*)charge block:(nonnull PinChargeResultBlock)block;

+ (void)fetchChargesInBackground:(nonnull PinChargeArrayResultBlock)block;

+ (void)fetchChargesInBackground:(nonnull NSNumber*)page block:(nonnull PinChargeArrayResultBlock)block;

+ (void)fetchChargesMatchingCriteriaInBackground:(nonnull PinChargeQuery*)query block:(nonnull PinChargeArrayResultBlock)block;

+ (void)fetchChargeDetailsInBackground:(nonnull NSString*)chargeToken block:(nonnull PinChargeResultBlock)block;

@end

typedef NS_ENUM(NSInteger, PinChargeQuerySortDirection) {
    PinChargeQuerySortDirectionAsc = 1,
    PinChargeQuerySortDirectionDesc = -1
} ;

typedef NS_ENUM(NSInteger, PinChargeQuerySortField) {
    PinChargeQuerySortFieldCreatedAt = 1,
    PinChargeQuerySortFieldDescription = 2,
    PinChargeQuerySortFieldAmount = 3
} ;

@interface PinChargeQuery : NSObject
@property (nullable, nonatomic, strong) NSString *query;
@property (nullable, nonatomic, strong) NSDate *startDate;
@property (nullable, nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) PinChargeQuerySortField sortField;
@property (nonatomic, assign) PinChargeQuerySortDirection direction;

- (nullable instancetype)init;

- (nonnull NSDictionary*)queryParameters;
@end





