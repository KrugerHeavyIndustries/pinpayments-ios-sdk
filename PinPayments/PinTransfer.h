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

@interface PinTransferLineItem : NSObject
@property (readonly, nullable, nonatomic, strong) NSString *type;
@property (readonly, nonatomic, assign) NSInteger amount;
@property (readonly, nullable, nonatomic, strong) NSString *currency;
@property (readonly, nullable, nonatomic, strong) NSDate *createdAt;
@property (readonly, nullable, nonatomic, strong) NSString *object;
@property (readonly, nullable, nonatomic, strong) NSString *token;
@end

@interface PinTransfer : NSObject

typedef void(^PinTransferResultBlock)(PinTransfer *_Nullable transfer, NSError *_Nullable error);
typedef void(^PinTransferArrayResultBlock)(NSArray<PinTransfer*> *_Nullable transfers, NSError *_Nullable error);
typedef void(^PinTransferLineItemsResultBlock)(NSArray<PinTransferLineItem*> *_Nullable lineItems, NSError *_Nullable error);

@property (readonly, nullable, nonatomic, strong) NSString *token;
@property (readonly, nullable, nonatomic, strong) NSString *status;
@property (readonly, nullable, nonatomic, strong) NSString *currency;
@property (readonly, nullable, nonatomic, strong) NSString *transferDescription;
@property (readonly, nonatomic, assign) NSInteger amount;
@property (readonly, nonatomic, assign) NSInteger totalDebits;
@property (readonly, nonatomic, assign) NSInteger totalCredits;
@property (readonly, nullable, nonatomic, strong) NSDate *createdAt;
@property (readonly, nullable, nonatomic, strong) NSDate *paidAt;
@property (readonly, nullable, nonatomic, strong) NSString *reference;
@property (readonly, nullable, nonatomic, strong) PinBankAccount *bankAccount;
@property (readonly, nullable, nonatomic, strong) NSString *recipient;

+ (void)createTransferInBackground:(nonnull PinTransfer*)transfer block:(nonnull PinTransferResultBlock)block;

+ (void)fetchTransfersInBackground:(nonnull PinTransferArrayResultBlock)block;

+ (void)fetchTransfersInBackground:(nonnull NSNumber*)page block:(nonnull PinTransferArrayResultBlock)block;

+ (void)fetchTransferDetailsInBackground:(nonnull NSString*)transferToken block:(nonnull PinTransferResultBlock)block;

+ (void)fetchTransferLineItemsInBackground:(nonnull NSString*)transferToken page:(NSInteger)page block:(nonnull PinTransferLineItemsResultBlock)block;

@end

