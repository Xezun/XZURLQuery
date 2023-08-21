//
//  ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ViewController.h"
@import XZURLQuery;

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZURLQuery *query = [XZURLQuery queryForURLString:@"https://xezun.com/?key1=x&key2=&key3=x&key3=&key3&key4"];
    query[@"name"] = @"John";
    query[@"key1"] = nil;
    query[@"key2"] = nil;
    query[@"key3"] = nil;
    query[@"ages"] = @[@"12", @"14"];
    [query addValue:@"Lily" forName:@"name"];
    NSLog(@"%@", query.url);
}


@end
