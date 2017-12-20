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
#import <PinPayments/NSDateFormatter+iso8601.h>

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

    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/charges"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"charges-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET charges";

    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/charges/ch_lfUYEBK14zotCTykezJkfg"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"charges-token-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET charges/token";

    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/charges/search"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"charges-search-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET charges/search";
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)testCharge:(PinCharge*)charge {
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
}

- (void)testCreateChargeInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"createChargeInBackground"];
    PinCharge *charge = [[PinCharge alloc] init];
    [PinCharge createChargeInBackground:charge block:^(PinCharge * _Nullable charge, NSError * _Nullable error) {
        [self testCharge:charge];
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchChargesInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchChargesInBackground"];
    [PinCharge fetchChargesInBackground:^(NSArray * _Nullable charges, NSError * _Nullable error) {
        XCTAssertTrue(charges.count > 0);
        PinCharge* charge = [charges firstObject];
        [self testCharge:charge];
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchChargesMatchingCriteriaInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchChargesMatchingCriteriaInBackground"];
    PinChargeQuery *query = [[PinChargeQuery alloc] init];
    [PinCharge fetchChargesMatchingCriteriaInBackground:query block:^(NSArray * _Nullable charges, NSError * _Nullable error) {
        XCTAssertTrue(charges.count > 0);
        PinCharge* charge = [charges firstObject];
        [self testCharge:charge];

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

-(void)testFetchChargeDetailsInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchChargeDetailsInBackground"];
    [PinCharge fetchChargeDetailsInBackground:@"ch_lfUYEBK14zotCTykezJkfg" block:^(PinCharge * _Nullable charge, NSError * _Nullable error) {
        [self testCharge:charge];
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

-(void)testPinChargeQueryQuery {
    PinChargeQuery *pinChargeQuery = [[PinChargeQuery alloc] init];
    pinChargeQuery.query = @"test charge";
    
    NSDictionary* parameters = [pinChargeQuery queryParameters];
    
    XCTAssertEqualObjects(parameters[@"query"], @"test charge");
    XCTAssertNil(parameters[@"start_date"]);
    XCTAssertNil(parameters[@"end_data"]);
    XCTAssertNil(parameters[@"sort"]);
    XCTAssertNil(parameters[@"direction"]);
}

-(void)testPinChargeQueryDates {
    PinChargeQuery *pinChargeQuery = [[PinChargeQuery alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    pinChargeQuery.startDate = [formatter dateFromString:@"2012-12-12"];
    pinChargeQuery.endDate = [formatter dateFromString:@"2013-06-01"];
    
    NSDictionary* parameters = [pinChargeQuery queryParameters];
    
    XCTAssertNil(parameters[@"query"]);
    XCTAssertEqualObjects(parameters[@"start_date"], @"2012/12/12");
    XCTAssertEqualObjects(parameters[@"end_date"], @"2013/06/01");
    XCTAssertNil(parameters[@"sort"]);
    XCTAssertNil(parameters[@"direction"]);
}

-(void)testPinChargeQueryDirection {
    PinChargeQuery *pinChargeQuery = [[PinChargeQuery alloc] init];
    pinChargeQuery.direction = PinChargeQuerySortDirectionAsc;
    
    NSDictionary* parameters = [pinChargeQuery queryParameters];
    
    XCTAssertNil(parameters[@"query"]);
    XCTAssertNil(parameters[@"start_date"]);
    XCTAssertNil(parameters[@"end_date"]);
    XCTAssertNil(parameters[@"sort"]);
    XCTAssertEqualObjects(parameters[@"direction"], [NSNumber numberWithInt:PinChargeQuerySortDirectionAsc]);
    
    pinChargeQuery.direction = PinChargeQuerySortDirectionDesc;
    parameters = [pinChargeQuery queryParameters];
    
    XCTAssertEqualObjects(parameters[@"direction"], [NSNumber numberWithInt:PinChargeQuerySortDirectionDesc]);
}

-(void)testPinChargeQuerySortField {
    PinChargeQuery *pinChargeQuery = [[PinChargeQuery alloc] init];
    pinChargeQuery.sortField = PinChargeQuerySortFieldCreatedAt;
    
    NSDictionary* parameters = [pinChargeQuery queryParameters];
    
    XCTAssertNil(parameters[@"query"]);
    XCTAssertNil(parameters[@"start_date"]);
    XCTAssertNil(parameters[@"end_date"]);
    XCTAssertEqualObjects(parameters[@"sort"], @"created_at");
    XCTAssertNil(parameters[@"direction"]);
    
    pinChargeQuery.sortField = PinChargeQuerySortFieldAmount;
    parameters = [pinChargeQuery queryParameters];
    
    XCTAssertEqualObjects(parameters[@"sort"], @"amount");
    
    pinChargeQuery.sortField = PinChargeQuerySortFieldDescription;
    parameters = [pinChargeQuery queryParameters];
    
    XCTAssertEqualObjects(parameters[@"sort"], @"description");
}
@end


