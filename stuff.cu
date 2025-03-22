typedef char s8;
typedef unsigned char u8;
typedef short s16;
typedef unsigned short u16;
typedef int s32;
typedef unsigned int u32;
typedef long long s64;
typedef unsigned long long u64;
#pragma once
#include <cmath>
#include "bitmap_image.hpp"
using namespace std;
double pi = 3.14159;

inline int
clamp(int min, int v, int max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
}
unsigned int convertColor(int r, int g, int b) {
    r = r*65536;
    g = g*256;
    int col = r + g + b;
    return (unsigned int)col;
}

bitmap_image grass("image.bmp");

unsigned int* uploadToGPU(bitmap_image img){
    unsigned int *GPUPointer = 0;
    unsigned int color = 0x000000;
    rgb_t c;
    cudaMalloc(&GPUPointer, img.width()*img.height()*sizeof(unsigned int));
    for(int i=0;i<img.width();i++){
        for(int j=0;j<img.height();j++){
            c = img.get_pixel(i, j);
            color = convertColor(c.red, c.green, c.blue);
            cudaMemcpy(GPUPointer+i+j*img.width(), &color, sizeof(unsigned int), cudaMemcpyHostToDevice);
        }
    }
    return GPUPointer;
}

unsigned int uvbmp(int u, int v, int z, bitmap_image image) {
    if(!image){
        return 0x000000;
    }
    int x = int((double(v)/255)*image.width());
    int y = int((double(u)/255)*image.height());
    rgb_t colour;
    image.get_pixel(x, y, colour);
    return convertColor(colour.red, colour.green, colour.blue);
}
