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

@interface PinCustomerTests : XCTestCase

@end

@implementation PinCustomerTests

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
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/1/customers"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customers-post.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:201 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"POST customers";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/customers"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customers-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET customers";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/customers/cus_XZg1ULpWaROQCOT5PdwLkQ"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customers-token-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET customers/token";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"PUT"] && [request.URL.path isEqualToString:@"/1/customers/cus_XZg1ULpWaROQCOT5PdwLkQ"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customers-token-put.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"PUT customers/token";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"DELETE"] && [request.URL.path isEqualToString:@"/1/customers/cus_XZg1ULpWaROQCOT5PdwLkQ"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:204 headers:nil];
    }];
    descriptor.name = @"DELETE customers/token";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/customers/cus_XZg1ULpWaROQCOT5PdwLkQ/charges"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customer-charges-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET customers/token/charges";
    
    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/customers/cus_XZg1ULpWaROQCOT5PdwLkQ/cards"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"customer-cards-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET customers/token/cards";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateCustomerInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"createCustomerInBackground"];
    PinCustomer *customer = [[PinCustomer alloc] init];
    [PinCustomer createCustomerInBackground:customer block:^(PinCustomer * _Nullable customer, NSError * _Nullable error) {
        XCTAssertEqualObjects(customer.token, @"cus_XZg1ULpWaROQCOT5PdwLkQ");
        XCTAssertEqualObjects(customer.email, @"roland@pinpayments.com");
        XCTAssertEqualObjects(customer.createdAt, @"2012-06-22T06:27:33Z");
        XCTAssertEqualObjects(customer.card.token, @"card_nytGw7koRg23EEp9NTmz9w");
        XCTAssertEqualObjects(customer.card.scheme, @"master");
        XCTAssertEqualObjects(customer.card.displayNumber, @"XXXX-XXXX-XXXX-0000");
        XCTAssertEqualObjects(customer.card.expiryMonth, @5);
        XCTAssertEqualObjects(customer.card.expiryYear, @2018);
        XCTAssertEqualObjects(customer.card.name, @"Roland Robot");
        
        XCTAssertEqualObjects(customer.card.addressPostcode, @"6454");
        XCTAssertEqualObjects(customer.card.addressState, @"WA");
        XCTAssertEqualObjects(customer.card.addressCountry, @"Australia");
        XCTAssertEqualObjects(customer.card.customerToken, @"cus_XZg1ULpWaROQCOT5PdwLkQ");
        XCTAssertTrue(customer.card.primary);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchCustomersInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchCustomersInBackground"];
    [PinCustomer fetchCustomersInBackground:^(NSArray<PinCustomer *> *_Nullable customers , NSError *_Nullable error) {
        XCTAssertTrue(customers.count > 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchCustomerDetailsInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchCustomerDetailsInBackground"];
    [PinCustomer fetchCustomerDetailsInBackground:@"cus_XZg1ULpWaROQCOT5PdwLkQ" block:^(PinCustomer * _Nullable customer, NSError * _Nullable error) {
        XCTAssertEqualObjects(customer.email, @"roland@pinpayments.com");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testUpdateCustomerDetailsInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"updateCustomersDetailsInBackground"];
    [PinCustomer updateCustomerDetailsInBackground:@"cus_XZg1ULpWaROQCOT5PdwLkQ" block:^(PinCustomer * _Nullable customer, NSError * _Nullable error) {
        XCTAssertEqualObjects(customer.email, @"roland@pinpayments.com");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testDeleteCustomerInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"deleteCustomerInBackground"];
    [PinCustomer deleteCustomerInBackground:@"cus_XZg1ULpWaROQCOT5PdwLkQ" block:^(bool done, NSError * _Nullable error) {
        XCTAssertTrue(done);
        XCTAssertNil(error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchCustomerChargesInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchCustomerChargesInBackground"];
    [PinCustomer fetchCustomerChargesInBackground:@"cus_XZg1ULpWaROQCOT5PdwLkQ" block:^(NSArray<PinCharge *> * _Nullable charges, NSError * _Nullable error) {
        XCTAssertTrue(charges.count > 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchCustomerCardsInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchCustomerCardsInBackground"];
    [PinCustomer fetchCustomerCardsInBackground:@"cus_XZg1ULpWaROQCOT5PdwLkQ" block:^(NSArray<PinCard *> * _Nullable cards, NSError * _Nullable error) {
        XCTAssertTrue(cards.count > 0);
        XCTAssertEqualObjects(cards.firstObject.token, @"card_nytGw7koRg23EEp9NTmz9w");
        XCTAssertEqualObjects(cards.firstObject.scheme, @"master");
        XCTAssertEqualObjects(cards.firstObject.displayNumber, @"XXXX-XXXX-XXXX-0000");
        XCTAssertEqualObjects(cards.firstObject.expiryMonth, @5);
        XCTAssertEqualObjects(cards.firstObject.expiryYear, @2018);
        XCTAssertEqualObjects(cards.firstObject.name, @"Roland Robot");
        XCTAssertEqualObjects(cards.firstObject.addressLine1, @"42 Sevenoaks St");
        XCTAssertEqualObjects(cards.firstObject.addressCity, @"Lathlain");
        XCTAssertEqualObjects(cards.firstObject.addressPostcode, @"6454");
        XCTAssertEqualObjects(cards.firstObject.addressState, @"WA");
        XCTAssertEqualObjects(cards.firstObject.addressCountry, @"Australia");
        XCTAssertEqualObjects(cards.firstObject.customerToken, @"cus_XZg1ULpWaROQCOT5PdwLkQ");
        XCTAssertTrue(cards.firstObject.primary);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

@end
