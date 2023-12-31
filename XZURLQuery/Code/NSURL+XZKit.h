//
//  NSURL+XZKit.h
//  XZURLQuery
//
//  Created by Xezun on 2023/7/30.
//

#import <Foundation/Foundation.h>

@class XZURLQuery;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (XZKit)

/// 获取 URL 的查询字段对象。
/// @note 这是一个计算属性，每次获取都是重新创建的值。
@property (nonatomic, copy, readonly) XZURLQuery *xz_query;

/// 创建 URL 对象。
/// @discussion 参数将直接添加 URL 中，因此需要自行编码。
+ (nullable instancetype)xz_URLWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/// 创建 URL 对象。
+ (nullable instancetype)xz_URLWithFormat:(NSString *)format arguments:(va_list)arguments;

@end

/// 构造 NSURL 对象的便利函数。
FOUNDATION_EXPORT NSURL * _Nullable XZURL(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT NSURL * _Nullable XZURLv(NSString *format, va_list arguments);

NS_ASSUME_NONNULL_END
