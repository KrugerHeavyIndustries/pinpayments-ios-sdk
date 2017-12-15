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

@implementation PinCard

+ (NSDictionary*)jsonMapping {
    return @{@"token": propertyKey(token),
             @"scheme": propertyKey(scheme),
             @"display_number": propertyKey(displayNumber),
             @"expiry_month": propertyKey(expiryMonth),
             @"expiry_year": propertyKey(expiryYear),
             @"name": propertyKey(name),
             @"address_line1": propertyKey(addressLine1),
             @"address_line2": propertyKey(addressLine2),
             @"address_city": propertyKey(addressCity),
             @"address_postcode": propertyKey(addressPostcode),
             @"address_state": propertyKey(addressState),
             @"address_country": propertyKey(addressCountry),
             @"customer_token": propertyKey(customerToken),
             @"primary": propertyKey(primary)};
}

+ (instancetype _Nullable)cardFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinCard *card = [[PinCard alloc] init];
    [card jsonSetValuesForKeysWithDictionary:dictionary];
    return card;
}

+ (void)createCardInBackground:(nonnull PinCard*)card block:(nonnull PinChardResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [card encodeIntoDictionary];
    [manager POST:@"cards" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinCard cardFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

-(nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinCard jsonMapping] allValues]];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PinCard: Number=%@", self.displayNumber];
}
@end
