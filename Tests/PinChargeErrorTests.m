// __  __ ______ _______ _______ _______ ______
// |  |/  |   __ \   |   |     __|    ___|   __ \
// |     <|      <   |   |    |  |    ___|      <
// |__|\__|___|__|_______|_______|_______|___|__|
//        H E A V Y  I N D U S T R I E S
//
// Copyright (C) 2018 Kruger Heavy Industries
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
#import <PinPayments/NSDateFormatter+iso8601.h>

@interface PinChargeErrorTests : XCTestCase
@end

@implementation PinChargeErrorTests

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
        NSString* fixture = OHPathForFile(@"charges-error.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:422 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"POST charges";
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)testChargeErrorInvalidResource:(PinChargeError*)chargeError {
    XCTAssertEqualObjects(chargeError.error, @"invalid_resource");
    XCTAssertEqualObjects(chargeError.errorDescription, @"One or more parameters were missing or invalid");
    XCTAssertTrue(chargeError.messages.count == 1);
    XCTAssertEqualObjects(chargeError.messages.firstObject[@"code"], @"description_invalid");
    XCTAssertEqualObjects(chargeError.messages.firstObject[@"message"], @"Description can't be blank");
    XCTAssertEqualObjects(chargeError.messages.firstObject[@"param"], @"description");
    XCTAssertNil(chargeError.chargeToken);
}

- (void)testCreateChargeInBackgroundWithError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"createChargeInBackground"];
    PinMutableCharge *charge = [[PinMutableCharge alloc] init];
    [PinCharge createChargeInBackground:charge block:^(PinCharge * _Nullable charge, PinChargeError * _Nullable error) {
        [self testChargeErrorInvalidResource:error];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}
@end
