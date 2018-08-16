//
//  Header.h
//  Pods
//
//  Created by 宇园 on 2018/8/16.
//

#ifndef Header_h
#define Header_h

#import "QGTool.h"

#pragma mark - Color

#define QG_UIColorHex(heQGalue) [UIColor colorWithRed:((CGFloat)((heQGalue & 0xFF0000) >> 16))/255.0f green:((CGFloat)((heQGalue & 0xFF00) >> 8))/255.0f blue:((CGFloat)(heQGalue & 0xFF))/255.0f alpha:1.0f]

#pragma mark - SYNTH_DUMMY_CLASS

/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 More info: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 Example:
 QGSYNTH_DUMMY_CLASS(NSString_YYAdd)
 */
#ifndef QGSYNTH_DUMMY_CLASS
#define QGSYNTH_DUMMY_CLASS(_name_) \
@interface QGSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation QGSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif

#pragma mark - QGSYNTH_DYNAMIC_PROPERTY_OBJECT

/**
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 QGSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 */
#ifndef QGSYNTH_DYNAMIC_PROPERTY_OBJECT
#define QGSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

#pragma mark - QGSYNTH_DYNAMIC_PROPERTY_CTYPE

/**
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 QGSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 */
#ifndef QGSYNTH_DYNAMIC_PROPERTY_CTYPE
#define QGSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}
#endif

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#pragma mark - QGTool

#define QG_iPhoneX [QGTool iPhoneX]
#define QG_StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height///< 该值根据是否显示状态栏会不同0 或 20 或 44
#define QG_DefaultStatusBarHeight (QG_iPhoneX ? 44.0f : 20.0f)
#define QG_NavigationBarHeight 44.0
#define QG_TabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49)

#define QG_iPhoneXBottomSpace 34.0f
#define QG_ViewControllerBottomSpace (QG_iPhoneX ? QG_iPhoneXBottomSpace : 0)

#endif /* Header_h */



