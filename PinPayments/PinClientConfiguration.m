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

#import <PinPayments/PinClientConfiguration.h>

NSString *const _PinDefaultServerURLString = @"https://api.pinpayments.com/1";
NSString *const _PinDefaultTestServerURLString = @"https://test-api.pin.net.au/1";

@implementation PinClientConfiguration

+ (instancetype)emptyConfiguration {
    return [[super alloc] initEmpty];
}

- (instancetype)initEmpty {
    self = [super init];
    if (!self) return nil;
    
    _server = [_PinDefaultServerURLString copy];
    
    return self;
}

- (instancetype _Nonnull)initWithBlock:(void (^)(id<PinMutableClientConfiguration>))configurationBlock {
    self = [self initEmpty];
    if (!self) return nil;
    
    configurationBlock(self);
    
    NSAssert(self.applicationId.length, @"`applicationId` should not be nil.");
    
    return self;
}

+ (instancetype)configurationWithBlock:(void (^)(id<PinMutableClientConfiguration>))configurationBlock {
    return [[self alloc] initWithBlock:configurationBlock];
}

///--------------------------------------
#pragma mark - Properties
///--------------------------------------

- (void)setApplicationId:(NSString *)applicationId {
    _applicationId = [applicationId copy];
}

- (void)setPublishableKey:(NSString *)publishableKey {
    _publishableKey = [publishableKey copy];
}

- (void)setSecretKey:(NSString *)secretKey {
    _secretKey = [secretKey copy];
}

- (void)setServer:(NSString *)server {
    _server = [server copy];
}

///--------------------------------------
#pragma mark - NSCopying
///--------------------------------------

- (instancetype)copyWithZone:(NSZone *)zone {
    return [PinClientConfiguration configurationWithBlock:^(PinClientConfiguration *configuration) {
        configuration->_applicationId = [self->_applicationId copy];
        configuration->_secretKey = [self->_secretKey copy];
        configuration->_publishableKey = [self->_publishableKey copy];
        configuration->_server = [self->_server copy];
    }];
}



@end
