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

@implementation PinBankAccount

+ (NSDictionary*)jsonMapping {
    return @{ @"token": propertyKey(token),
              @"name": propertyKey(name),
              @"bsb": propertyKey(bsb),
              @"number": propertyKey(number),
              @"bank_name": propertyKey(bankName),
              @"branch": propertyKey(branch) };
}

+ (instancetype _Nullable)accountFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinBankAccount *account = [[PinBankAccount alloc] init];
    [account jsonSetValuesForKeysWithDictionary:dictionary];
    return account;
}

+ (void)createBankAccountInBackground:(nonnull PinBankAccount*)account block:(nonnull PinBankAccountBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [account encodeIntoDictionary];
    [manager POST:@"bank_accounts" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinBankAccount accountFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

- (nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinBankAccount jsonMapping] allValues]];
}

@end
