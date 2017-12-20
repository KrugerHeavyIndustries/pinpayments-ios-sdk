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

@interface PinRecipient : NSObject

typedef void(^PinRecipientResultBlock)(PinRecipient *_Nullable recipient, NSError *_Nullable error);
typedef void(^PinRecipientsResultBlock)(NSArray<PinRecipient*> *_Nullable recipients, NSError *_Nullable error);
typedef void(^PinRecipientTransfersResultBlock)(NSArray<PinTransfer*> *_Nullable transfers, NSError *_Nullable error);

@property (readonly, nullable, nonatomic, strong) NSString *token;
@property (readonly, nullable, nonatomic, strong) NSString *name;
@property (readonly, nullable, nonatomic, strong) NSString *email;
@property (readonly, nullable, nonatomic, strong) NSDate *createdAt;
@property (readonly, nullable, nonatomic, strong) PinBankAccount *bankAccount;
@property (readonly, nullable, nonatomic, strong) NSString *bankAccountToken;

+ (void)createRecipientInBackground:(nonnull PinRecipient*)recipient block:(nonnull PinRecipientResultBlock)block;

+ (void)fetchRecipientsInBackground:(NSInteger)page block:(nonnull PinRecipientsResultBlock)block;

+ (void)fetchRecipientDetailsInBackground:(nonnull NSString*)recipientToken block:(nonnull PinRecipientResultBlock)block;

+ (void)fetchRecipientTransfersInBackground:(nonnull NSString*)recipientToken page:(NSInteger)page block:(nonnull PinRecipientTransfersResultBlock)block;

@end
