//
//  LinkedListQueue.m
//  FloodFillDemo
//
//  Created by LZR on 2018/8/31.
//  Copyright © 2018 Run. All rights reserved.
//

#import "LinkedListQueue.h"

static const int8_t kFinallyNodeOffset = -1;

@implementation LinkedListQueue

- (instancetype)init {
    return [self initWithCapacity:500 cacheSizeIncrements:500 multiplier:1000];
}

- (instancetype)initWithCapacity: (NSInteger)capacity cacheSizeIncrements: (NSInteger)increments multiplier: (NSInteger)multiplier {
    self = [super init];
    if (self) {
        _nodeCache = [NSMutableData dataWithLength:capacity * sizeof(PointNode)];
        _cacheSizeIncrements = increments;
        _multiplier =multiplier;
        _topNodeOffset = kFinallyNodeOffset;
        _freeNodeOffset = 0;
        [self initialiseNodeWithCount:capacity];
    }
    return self;
}

- (void)pushWithX: (NSInteger)x y: (NSInteger)y {
    PointNode *node = [self nextFreeNode];
    node->value = x * _multiplier + y;
    node->nextNodeOffset = _topNodeOffset;
    _topNodeOffset = [self offsetOfNode:node];
}

- (NSInteger)popWithX: (NSInteger *)x y: (NSInteger *)y {
    if (_topNodeOffset == kFinallyNodeOffset) return INVALID_NODE_CONTENT;
    PointNode *topNode = [self nodeOfOffset:_topNodeOffset];
    NSInteger value = topNode->value;
    NSInteger nextNodeOffset = topNode->nextNodeOffset;
    *x = value / _multiplier;
    *y = value % _multiplier;
    
    // reset
    topNode->value = 0;
    topNode->nextNodeOffset = _freeNodeOffset;
    _freeNodeOffset = _topNodeOffset;
    _topNodeOffset = nextNodeOffset;
    
    return value;
}

#pragma mark - Private

- (PointNode *)nodeOfOffset: (NSInteger)offset {
    return (PointNode *)_nodeCache.mutableBytes + offset;
}

- (NSInteger)offsetOfNode: (PointNode *)node {
    return node -  (PointNode *)_nodeCache.mutableBytes;
}

- (PointNode *)nextFreeNode {
    if (_freeNodeOffset < 0) {
        [_nodeCache increaseLengthBy:_cacheSizeIncrements * sizeof(PointNode)];
        _freeNodeOffset = _topNodeOffset + 1;
        [self initialiseNodeWithCount:_cacheSizeIncrements];
    }
    PointNode *node = (PointNode *)_nodeCache.mutableBytes + _freeNodeOffset;
    _freeNodeOffset = node->nextNodeOffset;
    return node;
}

/// 初始化节点
- (void)initialiseNodeWithCount: (NSInteger)count {
    PointNode *node = (PointNode *)_nodeCache.mutableBytes + _freeNodeOffset;
    for (int i = 0; i < count - 1; i ++) {
        node->value = 0;
        node->nextNodeOffset = _freeNodeOffset + i + 1;
        node ++;
    }
    node->value = 0;
    node->nextNodeOffset = kFinallyNodeOffset;
}

@end
