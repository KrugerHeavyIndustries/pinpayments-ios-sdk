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

@interface PinTransferTests : XCTestCase
@end

@implementation PinTransferTests

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
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"POST"] && [request.URL.path isEqualToString:@"/1/transfers"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"transfers-post.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:201 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"POST transfers";

    descriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.pinpayments.io"] && [request.HTTPMethod isEqualToString:@"GET"] && [request.URL.path isEqualToString:@"/1/transfers"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"transfers-get.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    descriptor.name = @"GET transfers";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateTransferInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"createTransferInBackground"];
    PinTransfer *transfer = [[PinTransfer alloc] init];
    [PinTransfer createTransferInBackground:transfer block:^(PinTransfer * _Nullable transfer, NSError * _Nullable error) {
        XCTAssertEqualObjects(transfer.token, @"tfer_lfUYEBK14zotCTykezJkfg");
        XCTAssertEqualObjects(transfer.status, @"succeeded");
        XCTAssertEqualObjects(transfer.currency, @"AUD");
        XCTAssertEqualObjects(transfer.transferDescription, @"Earnings for may");
        XCTAssertTrue(transfer.amount == 400);
        XCTAssertTrue(transfer.totalDebits == 200);
        XCTAssertTrue(transfer.totalCredits == 600);
        XCTAssertEqualObjects(transfer.createdAt, [[[NSDateFormatter alloc] init] dateFromISO8601:@"2012-06-20T03:10:49Z"]);
        XCTAssertEqualObjects(transfer.paidAt, [[[NSDateFormatter alloc] init] dateFromISO8601:@"2012-06-20T03:10:49Z"]);
        XCTAssertEqualObjects(transfer.reference, @"Test Business");
        XCTAssertEqualObjects(transfer.recipient, @"rp_a98a4fafROQCOT5PdwLkQ");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}

- (void)testFetchTransfersInBackground {
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchTransfersInBackground"];
    [PinTransfer fetchTransfersInBackground:^(NSArray * _Nullable transfers, NSError * _Nullable error) {
        XCTAssertTrue(transfers.count > 0);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
    }];
}


@end
