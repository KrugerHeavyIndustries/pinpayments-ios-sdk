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

@implementation PinTransferLineItem
+ (NSDictionary*)jsonMapping {
    return @{ @"type": propertyKey(type),
              @"amount": propertyKey(amount),
              @"currency": propertyKey(currency),
              @"created_at": propertyKey(createdAt),
              @"object": propertyKey(object),
              @"token": propertyKey(token) };
}

+ (instancetype _Nullable)lineItemFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinTransferLineItem *lineItem = [[PinTransferLineItem alloc] init];
    [lineItem jsonSetValuesForKeysWithDictionary:dictionary];
    return lineItem;
}

@end

@implementation PinTransfer

+ (NSDictionary*)jsonMapping {
    return @{ @"token": propertyKey(token),
              @"status": propertyKey(status),
              @"currency": propertyKey(currency),
              @"description": propertyKey(transferDescription),
              @"amount": propertyKey(amount),
              @"total_debits": propertyKey(totalDebits),
              @"total_credits": propertyKey(totalCredits),
              @"created_at": propertyKey(createdAt),
              @"paid_at": propertyKey(paidAt),
              @"reference": propertyKey(reference),
              @"bank_account": propertyKey(bankAccount),
              @"recipient": propertyKey(recipient) };
}

+ (instancetype _Nullable)transferFromDictionary:(nonnull NSDictionary *)dictionary {
    if (!dictionary || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    PinTransfer *card = [[PinTransfer alloc] init];
    [card jsonSetValuesForKeysWithDictionary:dictionary];
    return card;
}

+ (void)createTransferInBackground:(nonnull PinTransfer*)transfer block:(nonnull PinTransferResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerJson];
    NSDictionary* parameters = [transfer encodeIntoDictionary];
    [manager POST:@"transfers" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject) {
        block([PinTransfer transferFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchTransfersInBackground:(PinTransferArrayResultBlock)block {
    [PinTransfer fetchTransfersInBackground:@1 block:block];
}

+ (void)fetchTransfersInBackground:(nonnull NSNumber*)page block:(nonnull PinTransferArrayResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:@"transfers" parameters:@{ @"page": page } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *transfers = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *c in response) {
            [transfers addObject:[PinTransfer transferFromDictionary:c]];
        }
        block(transfers, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchTransferDetailsInBackground:(nonnull NSString*)transferToken block:(nonnull PinTransferResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"transfers/%@", transferToken] parameters:nil progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        block([PinTransfer transferFromDictionary:responseObject[@"response"]], nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

+ (void)fetchTransferLineItemsInBackground:(nonnull NSString*)transferToken page:(NSInteger)page block:(nonnull PinTransferLineItemsResultBlock)block {
    AFHTTPSessionManager *manager = [PinClient configuredSessionManager:RequestSerializerStandard];
    [manager GET:[NSString stringWithFormat:@"transfers/%@/line_items", transferToken] parameters:@{ @"page":[NSNumber numberWithLong:page] } progress:nil success:^(NSURLSessionDataTask *task , id _Nullable responseObject){
        NSMutableArray *lineItems = @[].mutableCopy;
        NSArray *response = responseObject[@"response"];
        for (NSDictionary *lineItem in response) {
            [lineItems addObject:[PinTransferLineItem lineItemFromDictionary:lineItem]];
        }
        block(lineItems, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        block(nil, error);
    }];
}

- (nonnull NSDictionary*)encodeIntoDictionary {
    return [self dictionaryWithValuesForKeys:[[PinTransfer jsonMapping] allValues]];
}

@end
