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

@implementation PinRecipient

+ (NSDictionary*)jsonMapping {
    return @{ @"token": propertyKey(token),
              @"name": propertyKey(name),
              @"email": propertyKey(email),
              @"created_at": propertyKey(createdAt),
              @"bank_account": propertyKey(bankAccount) };
}

+ (instancetype _Nullable)recipientFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinRecipient *recipient = [[PinRecipient alloc] init];
    [recipient jsonSetValuesForKeysWithDictionary:dictionary];
    return recipient;
}

+ (void)createRecipientInBackground:(nonnull PinRecipient*)recipient block:(nonnull PinRecipientResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [recipient encodeIntoDictionary];
    [manager POST:@"recipients" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        block([PinRecipient recipientFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchRecipientsInBackground:(NSInteger)page block:(nonnull PinRecipientsResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:@"recipients" parameters:@{ @"page": [NSNumber numberWithLong:page] } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *recipients = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *elem in response) {
            [recipients addObject:[PinRecipient recipientFromDictionary:elem]];
        }
        block(recipients, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchRecipientDetailsInBackground:(nonnull NSString*)recipientToken block:(nonnull PinRecipientResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    [manager GET:[NSString stringWithFormat:@"recipients/%@", recipientToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        block([PinRecipient recipientFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchRecipientTransfersInBackground:(nonnull NSString*)recipientToken page:(NSInteger)page block:(nonnull PinRecipientTransfersResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"recipients/%@/transfers", recipientToken] parameters:@{ @"page": [NSNumber numberWithLong:page] } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *transfers = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *elem in response) {
            [transfers addObject:[PinRecipient recipientFromDictionary:elem]];
        }
        block(transfers, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

- (nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinRecipient jsonMapping] allValues]];
}

@end
