//
//  QGChangeFrameVideoCompositionInstruction.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/28.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGChangeFrameVideoCompositionInstruction.h"

@interface QGChangeFrameVideoCompositionInstruction ()

@end

@implementation QGChangeFrameVideoCompositionInstruction

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeCMTime:_frameTime forKey:@"frameTime"];
    [aCoder encodeObject:_frameImage forKey:@"frameImage"];
    [aCoder encodeObject:_watermarkImage forKey:@"watermarkImage"];
    [aCoder encodeCGPoint:_watermarkPosition forKey:@"watermarkPosition"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.frameTime = [aDecoder decodeCMTimeForKey:@"frameTime"];
    self.frameImage = [aDecoder decodeObjectForKey:@"frameImage"];
    self.watermarkImage = [aDecoder decodeObjectForKey:@"watermarkImage"];
    self.watermarkPosition = [aDecoder decodeCGPointForKey:@"watermarkPosition"];
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    QGChangeFrameVideoCompositionInstruction *instruction = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return instruction;
}

@end
