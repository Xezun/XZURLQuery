//
//  XZURLQuery.m
//  XZURLQuery
//
//  Created by Xezun on 2023/7/30.
//

#import "XZURLQuery.h"

/// value 需事先检查为非 nil 值，返回 NSNull 或 NSString 对象。
static id XZURLQueryMakeValue(id _Nonnull value);

@interface XZURLQuery ()
@property (nonatomic, strong, readonly) NSURLComponents *components;
@end

@implementation XZURLQuery {
    NSURL *_url;
    /// \_keyedValues 是否已合并到 \_components 中。
    /// 为 YES 时，表示 \_keyedValues 已更新（可能为 nil)。
    BOOL _needsMergeKeyedValues;
    NSURLComponents *_components;
    NSMutableDictionary *_keyedValues;
}

+ (instancetype)queryForURL:(NSURL *)url {
    if (url == nil) return nil;
    return [[self alloc] initWithURL:url];
}

+ (instancetype)queryForURLString:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    if (url == nil) return nil;
    return [[self alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _needsMergeKeyedValues = NO;
        _url = url.copy;
        _keyedValues = nil;
    }
    return self;
}

- (NSURL *)url {
    if (_needsMergeKeyedValues) {
        _needsMergeKeyedValues = NO;
        if (_keyedValues.count == 0) {
            self.components.queryItems = nil;
        } else {
            NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:_keyedValues.count];
            [_keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:NSArray.class]) {
                    for (id value in obj) {
                        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:(value == NSNull.null ? nil : value)];
                        [arrayM addObject:item];
                    }
                } else {
                    NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:(obj == NSNull.null ? nil : obj)];
                    [arrayM addObject:item];
                }
            }];
            self.components.queryItems = arrayM;
        }
    }
    if (_components == nil) {
        return _url;
    }
    return _components.URL;
}

- (NSURLComponents *)components {
    if (_components == nil) {
        _components = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
    }
    return _components;
}

- (NSMutableDictionary *)keyedValues {
    if (_keyedValues == nil) {
        _keyedValues = [NSMutableDictionary dictionary];
        if (!_needsMergeKeyedValues) {
            for (NSURLQueryItem *item in self.components.queryItems) {
                NSString *name  = item.name;
                id        value = item.value ?: NSNull.null;
                NSMutableArray *oldValue = _keyedValues[name];
                if (oldValue == nil) {
                    _keyedValues[name] = value;
                } else if ([oldValue isKindOfClass:NSMutableArray.class]) {
                    [oldValue addObject:value];
                } else {
                    _keyedValues[name] = [NSMutableArray arrayWithObjects:oldValue, value, nil];
                }
            }
        }
    }
    return _keyedValues;
}

- (NSDictionary<NSString *,id> *)dictionaryRepresentation {
    return self.keyedValues.copy;
}

- (id)valueForName:(NSString *)name {
    id value = self.keyedValues[name];
    if (value == NSNull.null) {
        return nil;
    }
    return value;
}

- (void)setValue:(id)value forName:(NSString *)name {
    _needsMergeKeyedValues = YES;
    if (value == nil) {
        // 删除字段
        self.keyedValues[name] = nil;
    } else if ([value isKindOfClass:NSArray.class]) {
        // 设置为数组
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
        for (id object in (NSArray *)value) {
            [arrayM addObject:XZURLQueryMakeValue(object)];
        }
        self.keyedValues[name] = arrayM;
    } else {
        // 设置为值
        self.keyedValues[name] = XZURLQueryMakeValue(value);
    }
}

- (void)addValue:(id)value forName:(NSString *)name {
    _needsMergeKeyedValues = YES;
    if (value == nil) {
        [self _addValue:NSNull.null forName:name];
    } else if ([value isKindOfClass:NSArray.class]) {
        for (NSObject *object in value) {
            [self _addValue:XZURLQueryMakeValue(object) forName:value];
        }
    } else {
        [self _addValue:XZURLQueryMakeValue(value) forName:name];
    }
}

- (void)_addValue:(id)value forName:(NSString *)name {
    NSMutableArray<NSURLQueryItem *> *oldValue = self.keyedValues[name];
    if ([oldValue isKindOfClass:NSMutableArray.class]) {
        [oldValue addObject:value];
    } else if (oldValue == nil) {
        self.keyedValues[name] = value;
    } else {
        oldValue = [NSMutableArray arrayWithObjects:oldValue, value, nil];
        self.keyedValues[name] = oldValue;
    }
}

- (void)removeAllFields {
    _needsMergeKeyedValues = YES;
    [_keyedValues removeAllObjects];
}

- (id)objectForKeyedSubscript:(NSString *)name {
    return [self valueForName:name];
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)name {
    [self setValue:value forName:name];
}

- (BOOL)containsValueForName:(NSString *)name {
    return [_keyedValues objectForKey:name] != nil;
}

- (NSString *)stringForName:(NSString *)name {
    id value = self.keyedValues[name];
    if (value == nil) {
        return nil;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if (value == NSNull.null) {
        return nil;
    }
    value = [(NSArray *)value firstObject];
    if (value == NSNull.null) {
        return nil;
    }
    return value;
}

- (NSArray<NSString *> *)arrayForName:(NSString *)name {
    id value = self.keyedValues[name];
    if (value == nil) {
        return nil;
    }
    if ([value isKindOfClass:NSArray.class]) {
        return value;
    }
    return @[value];
}

- (NSInteger)integerForName:(NSString *)name {
    return [[self stringForName:name] integerValue];
}

- (NSURL *)urlForName:(NSString *)name {
    NSString *string = [self stringForName:name];
    if (string == nil) {
        return nil;
    }
    return [NSURL URLWithString:string];
}

- (void)addFieldsFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addValue:obj forName:key];
    }];
}

- (void)setFieldsWithDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forName:key];
    }];
}

@end

static id XZURLQueryMakeValue(id value) {
    if (value == NSNull.null || [value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([NSJSONSerialization isValidJSONObject:value]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return [value description];
}
