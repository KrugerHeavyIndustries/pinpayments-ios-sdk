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

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>

#import "PinPayments.h"
#import "PinPayments/NSDateFormatter+iso8601.h"

@interface PinChargeTests : XCTestCase

@end

@implementation PinChargeTests

- (void)setUp {
    [super setUp];
    
    [PinClient initializeWithConfiguration:[PinClientConfiguration configurationWithBlock:^(id<PinMutableClientConfiguration> _Nonnull configuration) {
        configuration.applicationId = @"your_application_id";
        configuration.publishableKey = @"pk_your_publishable_key";
        configuration.secretKey = @"your_secret_key";
        configuration.server = @"https://api.pinpayments.io/1";
    }]];
    
    [OHHTTPStubs onStubActivation:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor> _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
        NSLog(@"[OHHTTPStubs] Request to %@ has been stubbed with %@", request.URL, stub.name);
    }];
    
   __weak id<OHHTTPStubsDescriptor> descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/1/charges"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"charges-post.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:201 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"POST charges";
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)testCreateChargeInBackground {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"createChargeInBackground"];
    
    PinCharge *charge = [PinCharge alloc];
    [PinCharge createChargeInBackground:charge block:^(PinCharge * _Nullable charge, NSError * _Nullable error) {
        XCTAssertEqualObjects(charge.email, @"roland@pinpayments.com");
        XCTAssertEqualObjects(charge.chargeDescription, @"test charge");
        XCTAssertEqual(charge.amount, 400);
        XCTAssertEqualObjects(charge.ipAddress, @"203.192.1.172");
        XCTAssertEqualObjects(charge.created, [[[NSDateFormatter alloc] init] dateFromISO8601:@"2012-06-20T03:10:49Z"]);
        XCTAssertEqualObjects(charge.currency, @"USD");
        XCTAssertTrue(charge.success);
        XCTAssertEqualObjects(charge.statusMessage, @"Success");
        XCTAssertTrue(charge.errorMessage.length == 0);
        
        XCTAssertEqualObjects(charge.card.token, @"card_pIQJKMs93GsCc9vLSLevbw");
        XCTAssertEqualObjects(charge.card.scheme, @"master");
        XCTAssertEqualObjects(charge.card.displayNumber, @"XXXX-XXXX-XXXX-0000");
        XCTAssertEqualObjects(charge.card.expiryMonth, @5);
        XCTAssertEqualObjects(charge.card.expiryYear, @2018);
        XCTAssertEqualObjects(charge.card.name, @"Roland Robot");
        XCTAssertEqualObjects(charge.card.addressLine1, @"42 Sevenoaks St");
        XCTAssertTrue(charge.card.addressLine2.length == 0);
        XCTAssertEqualObjects(charge.card.addressCity, @"Lathlain");
        XCTAssertEqualObjects(charge.card.addressPostcode, @"6454");
        XCTAssertEqualObjects(charge.card.addressState, @"WA");
        XCTAssertEqualObjects(charge.card.addressCountry, @"Australia");
        XCTAssertTrue(charge.card.customerToken.length == 0);
        XCTAssertNil(charge.card.primary);
        
        XCTAssertFalse(charge.authorizationExpired);
        XCTAssertNil(charge.cardToken);
        XCTAssertNil(charge.customerToken);
        XCTAssertEqualObjects(charge.token, @"ch_lfUYEBK14zotCTykezJkfg");
            
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        // handle failure
    }];
}

@end
