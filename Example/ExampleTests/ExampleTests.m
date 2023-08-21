//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Xezun on 2023/7/27.
//

#import <XCTest/XCTest.h>
@import XZURLQuery;

@interface ExampleTests : XCTestCase

@end

@implementation ExampleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    XZURLQuery *query = [XZURLQuery queryForURLString:@"https://www.xezun.com/?key1=value1&key2=&key3"];;
    NSLog(@"原始：%@", query.url);
    
    XCTAssert([[query valueForName:@"key1"] isEqual:@"value1"]);
    XCTAssert([[query valueForName:@"key2"] isEqual:@""]);
    XCTAssert([query valueForName:@"key3"] == nil);
    XCTAssert([query valueForName:@"key4"] == nil);
    
    [query setValue:@"123" forName:@"key4"];
    XCTAssert([[query valueForName:@"key4"] isEqual:@"123"]);
    NSLog(@"设置 key4 = 123：%@", query.url);
    
    [query addValue:@"1" forName:@"key4"];
    NSLog(@"添加 key4 = 1  ：%@", query.url);
    
    [query addValue:nil forName:@"key4"];
    NSLog(@"添加 key4 = nil：%@", query.url);
    
    [query setValue:nil forName:@"key4"];
    NSLog(@"移除 key4      ：%@", query.url);
    
    [query setValue:nil forName:@"key1"];
    NSLog(@"移除 key1      ：%@", query.url);
    
    XCTAssert(![query containsValueForName:@"key1"]);
    XCTAssert([query containsValueForName:@"key2"]);
    XCTAssert([query containsValueForName:@"key3"]);
    XCTAssert(![query containsValueForName:@"key4"]);
    XCTAssert(![query containsValueForName:@"key5"]);
    
    [query addFieldsFromDictionary:@{
        @"A": @"1",
        @"B": @"2",
        @"C": @"3",
        @"D": @"4"
    }];
    NSLog(@"添加字典字段     ：%@", query.url);
    
    [query addFieldsFromDictionary:@{
        @"A": @"x1",
        @"B": @"x2",
        @"C": @"x3",
        @"D": @"x4"
    }];
    NSLog(@"添加字典字段     ：%@", query.url);
    
    [query setFieldsWithDictionary:@{
        @"A": @"4",
        @"B": @"3",
        @"C": @"2",
        @"D": @"1"
    }];
    NSLog(@"设置字典字段     ：%@", query.url);
    
    [query removeAllFields];
    NSLog(@"移除所有字段     ：%@", query.url);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
