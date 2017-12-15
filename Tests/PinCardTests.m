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

#import <PinPayments/PinPayments.h>

@interface PinCardTests : XCTestCase
@end

@implementation PinCardTests
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
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/1/cards"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"cards-post.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:201 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"POST cards";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateCardInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"createCardInBackground"];
    PinCard *card = [[PinCard alloc] init];
    [PinCard createCardInBackground:card block:^(PinCard * _Nullable card, NSError * _Nullable error) {
        XCTAssertEqualObjects(card.token, @"card_pIQJKMs93GsCc9vLSLevbw");
        XCTAssertEqualObjects(card.scheme, @"master");
        XCTAssertEqualObjects(card.displayNumber, @"XXXX-XXXX-XXXX-0000");
        XCTAssertEqualObjects(card.expiryMonth, @5);
        XCTAssertEqualObjects(card.expiryYear, @2018);
        XCTAssertEqualObjects(card.name, @"Roland Robot");
        XCTAssertEqualObjects(card.addressLine1, @"42 Sevenoaks St");
        XCTAssertEqualObjects(card.addressLine2, @"");
        XCTAssertEqualObjects(card.addressCity, @"Lathlain");
        XCTAssertEqualObjects(card.addressPostcode, @"6454");
        XCTAssertEqualObjects(card.addressState, @"WA");
        XCTAssertEqualObjects(card.addressCountry, @"Australia");
        XCTAssertEqualObjects(card.customerToken, @"");
        XCTAssertNil(card.primary);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}
@end
