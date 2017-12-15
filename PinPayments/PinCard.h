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

@interface PinCard : NSObject

typedef void(^PinChardResultBlock)(PinCard * _Nullable charge, NSError * _Nullable error);

@property (nullable, nonatomic, strong) NSString *token;
@property (nullable, nonatomic, strong) NSString *scheme;
@property (nullable, nonatomic, strong) NSString *displayNumber;
@property (nullable, nonatomic, strong) NSNumber *expiryMonth;
@property (nullable, nonatomic, strong) NSNumber *expiryYear;
@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSString *addressLine1;
@property (nullable, nonatomic, strong) NSString *addressLine2;
@property (nullable, nonatomic, strong) NSString *addressCity;
@property (nullable, nonatomic, strong) NSString *addressPostcode;
@property (nullable, nonatomic, strong) NSString *addressState;
@property (nullable, nonatomic, strong) NSString *addressCountry;
@property (nullable, nonatomic, strong) NSString *customerToken;
@property (nullable, nonatomic, strong) NSNumber *primary;

+ (instancetype _Nullable)cardFromDictionary:(nonnull NSDictionary *)dictionary;

+ (void)createCardInBackground:(nonnull PinCard*)card block:(nonnull PinChardResultBlock)block;

@end
