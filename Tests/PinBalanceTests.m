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

@interface PinBalanceTests : XCTestCase
@end

@implementation PinBalanceTests

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
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/balance"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"balance-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET balance";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchBalanceInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchBalanceInBackground"];
    [PinBalance fetchBalanceInBackground:^(PinBalance *balance, NSError *error) {
        XCTAssertTrue(balance.available.firstObject.amount == 400);
        XCTAssertEqualObjects(balance.available.firstObject.currency, @"AUD");
        XCTAssertTrue(balance.pending.firstObject.amount == 1200);
        XCTAssertEqualObjects(balance.pending.firstObject.currency, @"AUD");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

@end
