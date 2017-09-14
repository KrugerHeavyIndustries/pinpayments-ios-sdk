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

@interface PinCharge : NSObject

typedef void(^PinChargeResultBlock)(PinCharge * _Nullable charge, NSError * _Nullable error);

@property (nullable, nonatomic, strong) NSString *email;
@property (nullable, nonatomic, strong) NSString *chargeDescription;
@property (nonatomic, assign) NSInteger amount;
@property (nullable, nonatomic, strong) NSString *ipAddress;
@property (nullable, nonatomic, strong) NSDate *created;
@property (nullable, nonatomic, strong) NSString *currency;
@property (nonatomic, assign) BOOL capture;
@property (nonatomic, assign) BOOL success;
@property (nullable, nonatomic, strong) NSString *statusMessage;
@property (nullable, nonatomic, strong) NSString *errorMessage;
@property (nullable, nonatomic, strong) PinCard *card;
@property (nonatomic, assign) BOOL authorizationExpired;
@property (nullable, nonatomic, strong) NSString *token;
@property (nullable, nonatomic, strong) NSString *cardToken;
@property (nullable, nonatomic, strong) NSString *customerToken;
@property (nullable, nonatomic, strong) NSDictionary *metadata;

+(void)createChargeInBackground:(nonnull PinCharge*)charge block:(nullable PinChargeResultBlock)block;

+(void)fetchChargesInBackground;

+(void)fetchChargesInBackground:(nullable NSNumber*)page;

@end





