#pragma once
#include "stuff.cu"
#include "window.cu"
#include <cmath>
void cpuclearscreen(unsigned int color){
    unsigned int* pixel = (unsigned int*)buffermem;
    for (int y = 0; y < bheight; y++) {
        for (int x = 0; x < bwidth; x++){
            *pixel++ = color;}}}
void cpudrawLine(int x1, int y1, int x2, int y2, unsigned int c){
    if(y1 == y2) {
        if(x1 <= x2) {
            if(x1>=0 && x2 < bwidth){
                unsigned int* pixel = (unsigned int*)buffermem + x1 + y1*bwidth;
                for (int x = x1; x < x2; x++){
                    if(!(x<0 || x>=bwidth || y1<0 || y1>=bheight)){
                        *pixel++ = c;
                    }
                }
            }
        }
        unsigned int* pixel = (unsigned int*)buffermem + x2 + y2*bwidth;
        for (int x = x2; x < x1; x++){
            if(!(x<0 || x>=bwidth || y1<0 || y1>=bheight)){
                *pixel++ = c;
            }
        }
    }
    int ux = x1; int uy = y1; int dx = x2; int dy = y2;
    if(abs(y2-y1) > abs(x2-x1)) {
        if(y2 > y1) {ux = x2; uy = y2; dx = x1; dy = y1;}
        int xx;
        for(int y=dy;y<uy;y++){
            xx = int(ux+(dx-ux)*(double(uy-y)/double(uy-dy)));
            if(!(xx<0 || xx>=bwidth || y<0 || y>=bheight)){
                unsigned int* pixel = (unsigned int*)buffermem + xx + y*bwidth;
                *pixel = c;
            }
        }
    }else{
        if(x2 > x1) {ux = x2; uy = y2; dx = x1; dy = y1;}
        int yy;
        for(int x=dx;x<ux;x++){
            yy = int(uy+(dy-uy)*(double(ux-x)/double(ux-dx)));
            if(!(x<0 || x>=bwidth || yy<0 || yy>=bheight)){
                unsigned int* pixel = (unsigned int*)buffermem + x + yy*bwidth;
                *pixel = c;
            }
        }
    }
}
void cpudrawRect(int xpos, int ypos, int rWidth, int rHeight, unsigned int color){
    if(xpos >= bwidth || ypos >= bheight) return;
    rWidth = clamp(0,rWidth,bwidth-xpos);
    rHeight = clamp(0,rHeight,bheight-ypos);
    if(ypos < 0) {rHeight += ypos; ypos = 0;};
    if(xpos < 0) {rWidth += xpos; xpos = 0;};
    if(rWidth <=0 || rHeight <=0) return;
    for (int y = ypos; y < ypos+rHeight; y++) {
        unsigned int* pixel = (unsigned int*)buffermem + xpos + y*bwidth;
        for (int x = xpos; x < xpos+rWidth; x++){
            *pixel++ = color;}}
}
void cpudrawImg(int xpos, int ypos, int rWidth, int rHeight, bitmap_image img){
    if(xpos >= bwidth || ypos >= bheight) return;
    unsigned int color;
    rgb_t c;
    rWidth = clamp(0,rWidth,bwidth-xpos);
    rHeight = clamp(0,rHeight,bheight-ypos);
    if(ypos < 0) {rHeight += ypos; ypos = 0;};
    if(xpos < 0) {rWidth += xpos; xpos = 0;};
    if(rWidth <=0 || rHeight <=0) return;
    for (int y = ypos; y < ypos+rHeight; y++) {
        unsigned int* pixel = (unsigned int*)buffermem + xpos + y*bwidth;
        for (int x = xpos; x < xpos+rWidth; x++){
            c = img.get_pixel(int(img.width() * (double(x - xpos)/rWidth)), int(img.height() * (double(y - ypos)/rHeight)));
            color = convertColor(c.red,c.green,c.blue);
            *pixel++ = color;}}
}
void cputri(int x0, int y0, int x1, int y1, int x2, int y2, int r0, int g0, int b0, int r1, int g1, int b1, int r2, int g2, int b2, bitmap_image img){
    r0 = clamp(0,r0,255);
    g0 = clamp(0,g0,255);
    b0 = clamp(0,b0,255);
    r1 = clamp(0,r1,255);
    g1 = clamp(0,g1,255);
    b1 = clamp(0,b1,255);
    r2 = clamp(0,r2,255);
    g2 = clamp(0,g2,255);
    b2 = clamp(0,b2,255);
    if(y0 == y1 && y1 == y2){
        return;
    }
    int tstart = y0; int ustart = x0; int rstart = r0; int gstart = g0; int bstart = b0; int st = 0;
    if (y1<tstart) {tstart = y1; ustart = x1; rstart = r1; gstart = g1; bstart = b1; st = 1;}
    if (y2<tstart) {tstart = y2; ustart = x2; rstart = r2; gstart = g2; bstart = b2; st = 2;}
    int tend = y0; int uend = x0; int rend = r0; int gend = g0; int bend = b0; int nd = 0;
    if (y1>tend) {tend = y1; uend = x1; rend = r1; gend = g1; bend = b1; nd = 1;}
    if (y2>tend) {tend = y2; uend = x2; rend = r2; gend = g2; bend = b2; nd = 2;}
    int tmid = y0; int umid = x0; int rmid = r0; int gmid = g0; int bmid = b0;
    if (nd + st == 2) {tmid = y1; umid = x1; rmid = r1; gmid = g1; bmid = b1;}
    if (nd + st == 1) {tmid = y2; umid = x2; rmid = r2; gmid = g2; bmid = b2;}
    int u0, u1; //un
    int ra,rb,ga,gb,ba,bb,fr,fg,fb;
    for (int t=tstart;t<tmid;t++) {
        if(tmid == tstart){
            break;
        }
        if (t > 0 && t < bheight) {
            u0 = int((float(t - tstart)/float(tend - tstart)) * (uend - ustart));
            u1 = int((float(t - tstart)/float(tmid - tstart)) * (umid - ustart));
            ra = rstart+((float(t - tstart)/float(tend - tstart)) * (rend - rstart));
            ga = gstart+((float(t - tstart)/float(tend - tstart)) * (gend - gstart));
            ba = bstart+((float(t - tstart)/float(tend - tstart)) * (bend - bstart));
            rb = rstart+((float(t - tstart)/float(tmid - tstart)) * (rmid - rstart));
            gb = gstart+((float(t - tstart)/float(tmid - tstart)) * (gmid - gstart));
            bb = bstart+((float(t - tstart)/float(tmid - tstart)) * (bmid - bstart));
            if (u0+ustart <= u1+ustart) {
                if(u0+ustart > 0 && u1+ustart < bwidth){
                    unsigned int* pixel = (unsigned int*)buffermem + u0+ustart + t*bwidth;
                    for (int u=u0+ustart;u<u1+ustart;u++){
                        fr = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(rb-ra)+ra;
                        fg = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(gb-ga)+ga;
                        fb = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(bb-ba)+ba;
                        *pixel++ = uvbmp(fr, fg, fb, img);
                    }
                }else{
                    if(u0+ustart > 0) {
                        unsigned int* pixel = (unsigned int*)buffermem + u0+ustart + t*bwidth;
                        for (int u=u0+ustart;u<bwidth;u++){
                            fr = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(rb-ra)+ra;
                            fg = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(gb-ga)+ga;
                            fb = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(bb-ba)+ba;
                            *pixel++ = uvbmp(fr, fg, fb, img);
                        }
                    }else{
                        if(u1+ustart < bwidth) {
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<u1+ustart;u++){
                                fr = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(rb-ra)+ra;
                                fg = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(gb-ga)+ga;
                                fb = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(bb-ba)+ba;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }else{
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<bwidth;u++){
                                fr = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(rb-ra)+ra;
                                fg = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(gb-ga)+ga;
                                fb = (float(u-(u0+ustart))/float((u1+ustart)-(u0+ustart)))*(bb-ba)+ba;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }
                    }
                }
            }
            if (u0+ustart > u1+ustart) {
                if (u1+ustart > 0 && u0+ustart < bwidth) {
                    unsigned int* pixel = (unsigned int*)buffermem + u1+ustart + t*bwidth;
                    for (int u=u1+ustart;u<u0+ustart;u++){
                        fr = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ra-rb)+rb;
                        fg = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ga-gb)+gb;
                        fb = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ba-bb)+bb;
                        *pixel++ = uvbmp(fr, fg, fb, img);
                    }
                }else{
                    if(u1+ustart > 0) {
                        unsigned int* pixel = (unsigned int*)buffermem + u1+ustart + t*bwidth;
                        for (int u=u1+ustart;u<bwidth;u++){
                            fr = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ra-rb)+rb;
                            fg = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ga-gb)+gb;
                            fb = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ba-bb)+bb;
                            *pixel++ = uvbmp(fr, fg, fb, img);
                        }
                    }else{
                        if(u0+ustart < bwidth) {
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<u0+ustart;u++){
                                fr = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ra-rb)+rb;
                                fg = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ga-gb)+gb;
                                fb = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ba-bb)+bb;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }else{
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<bwidth;u++){
                                fr = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ra-rb)+rb;
                                fg = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ga-gb)+gb;
                                fb = (float(u-(u1+ustart))/float((u0+ustart)-(u1+ustart)))*(ba-bb)+bb;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }
                    }
                }
            }
        }
    }
    for (int t=tmid;t<tend;t++) {
        if(tmid == tend){
            break;
        }
        if (t > 0 && t < bheight) {
            u0 = int((float(t - tstart)/float(tend - tstart)) * (uend - ustart));
            u1 = int((float(t - tmid)/float(tend - tmid)) * (uend - umid));
            ra = rstart+((float(t - tstart)/float(tend - tstart)) * (rend - rstart));
            ga = gstart+((float(t - tstart)/float(tend - tstart)) * (gend - gstart));
            ba = bstart+((float(t - tstart)/float(tend - tstart)) * (bend - bstart));
            rb = rmid+int((float(t - tmid)/float(tend - tmid)) * (rend - rmid));
            gb = gmid+int((float(t - tmid)/float(tend - tmid)) * (gend - gmid));
            bb = bmid+int((float(t - tmid)/float(tend - tmid)) * (bend - bmid));
            if (u0+ustart <= u1+umid) {
                if (u0 + ustart > 0 && u1 + umid < bwidth) {
                    unsigned int* pixel = (unsigned int*)buffermem + u0+ustart + t*bwidth;
                    for (int u=u0+ustart;u<u1+umid;u++){
                        fr = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(rb-ra)+ra;
                        fg = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(gb-ga)+ga;
                        fb = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(bb-ba)+ba;
                        *pixel++ = uvbmp(fr, fg, fb, img);
                    }
                }else{
                    if(u0+ustart > 0) {
                        unsigned int* pixel = (unsigned int*)buffermem + u0+ustart + t*bwidth;
                        for (int u=u0+ustart;u<bwidth;u++){
                            fr = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(rb-ra)+ra;
                            fg = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(gb-ga)+ga;
                            fb = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(bb-ba)+ba;
                            *pixel++ = uvbmp(fr, fg, fb, img);
                        }
                    }else{
                        if(u1+umid < bwidth) {
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<u1+umid;u++){
                                fr = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(rb-ra)+ra;
                                fg = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(gb-ga)+ga;
                                fb = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(bb-ba)+ba;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }else{
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<bwidth;u++){
                                fr = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(rb-ra)+ra;
                                fg = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(gb-ga)+ga;
                                fb = (float(u-(u0+ustart))/float((u1+umid)-(u0+ustart)))*(bb-ba)+ba;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }
                    }
                }
            }
            if (u0+ustart > u1+umid) {
                if (u1 + umid > 0 && u0 + ustart < bwidth) {
                    unsigned int* pixel = (unsigned int*)buffermem + u1+umid + t*bwidth;
                    for (int u=u1+umid;u<u0+ustart;u++){
                        fr = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ra-rb)+rb;
                        fg = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ga-gb)+gb;
                        fb = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ba-bb)+bb;
                        *pixel++ = uvbmp(fr, fg, fb, img);
                    }
                }else{
                    if(u1+umid > 0) {
                        unsigned int* pixel = (unsigned int*)buffermem + u1+umid + t*bwidth;
                        for (int u=u1+umid;u<bwidth;u++){
                            fr = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ra-rb)+rb;
                            fg = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ga-gb)+gb;
                            fb = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ba-bb)+bb;
                            *pixel++ = uvbmp(fr, fg, fb, img);
                        }
                    }else{
                        if(u0+ustart < bwidth) {
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<u0+ustart;u++){
                                fr = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ra-rb)+rb;
                                fg = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ga-gb)+gb;
                                fb = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ba-bb)+bb;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }else{
                            unsigned int* pixel = (unsigned int*)buffermem + t*bwidth;
                            for (int u=0;u<bwidth;u++){
                                fr = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ra-rb)+rb;
                                fg = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ga-gb)+gb;
                                fb = (float(u-(u1+umid))/float((u0+ustart)-(u1+umid)))*(ba-bb)+bb;
                                *pixel++ = uvbmp(fr, fg, fb, img);
                            }
                        }
                    }
                }
            }
        }
    }
}

__global__ void clearRect(unsigned int* address, unsigned int color, int posX, int posY){
    unsigned int* pixel = address+blockIdx.x+posX+(threadIdx.x+posY)*640;
    if(threadIdx.x+posY<480&&blockIdx.x+posX<640&&int(blockIdx.x)+posX>=0&&int(threadIdx.x)+posY>=0) *pixel = color;
} //clearrect<<<width, height>>>(pointer, color, X, Y)

__global__ void drawImg(unsigned int* address, unsigned int* image, int posX, int posY, int W, int H, int imageW, int imageH){
    unsigned int* pixel = address+blockIdx.x+posX+(threadIdx.x+posY)*640;
    unsigned int color = image[int(float(imageW)*float(blockIdx.x)/float(W)) + int(float(imageH)*float(threadIdx.x)/float(H))*imageW];
    if(threadIdx.x+posY<480&&blockIdx.x+posX<640&&int(blockIdx.x)+posX>=0&&int(threadIdx.x)+posY>=0) *pixel = color;
} //drawImg<<<width, height>>>(pointer, image, X, Y, width, height)

__global__ void triangle(unsigned int* address, vertexdat p1, vertexdat p2, vertexdat p3, unsigned int* image, unsigned int imgW, unsigned int imgH, unsigned int* zbuffer){
    int x, y, ix, iy;
    float t, s;
    if(abs(p2.x-p1.x)>abs(p2.y-p1.y)){
        t = float(threadIdx.x)/float(abs(p2.x-p1.x)+2);
    }else{
        t = float(threadIdx.x)/float(abs(p2.y-p1.y)+2);
    }
    if(abs(p3.x-p1.x)>abs(p3.y-p1.y)){
        s = float(blockIdx.x)/float(abs(p3.x-p1.x)+2);
    }else{
        s = float(blockIdx.x)/float(abs(p3.y-p1.y)+2);
    }
    x = p1.x + int(t*float(p2.x-p1.x)) + int(s*float(p3.x-p1.x));
    y = p1.y + int(t*float(p2.y-p1.y)) + int(s*float(p3.y-p1.y));
    unsigned int*  pixel = address + x + y*640;
    unsigned int* zpixel = zbuffer + x + y*640;
    unsigned int z = p1.depth + int(t*float(p2.depth-p1.depth)) + int(s*float(p3.depth-p1.depth));
    if(y<480&&x<640&&x>=0&&y>=0&&s+t<1) {
        if(z<*zpixel&&z>0){
            *zpixel = z;
            if(imgW==0x00) {
                *pixel = imgH;
            }else{
                ix = imgW*(p1.u*(1-t-s) + p2.u*t + p3.u*s)/256;
                iy = imgH*(p1.v*(1-t-s) + p2.v*t + p3.v*s)/256;
                *pixel = *(image+ix+iy*imgW);
            }
        }
    }
}

__global__ void mdraw(unsigned int* address, matrix m, model* mdl, unsigned int* image, unsigned int imgW, unsigned int imgH, u32 sw, u32 sh, float fovm, unsigned int* zbuffer){
    vertex passvert[3] = {0, 0, 0, 0, 0, 0, 0, 0, 0}; vertex passver[3] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    passvert[0].x = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].x;
    passvert[0].y = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].y;
    passvert[0].z = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].z;
    passvert[1].x = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].x;
    passvert[1].y = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].y;
    passvert[1].z = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].z;
    passvert[2].x = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].x;
    passvert[2].y = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].y;
    passvert[2].z = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].z;

    /*((float*)address)[blockIdx.x*18+0] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].x;
    ((float*)address)[blockIdx.x*18+1] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].y;
    ((float*)address)[blockIdx.x*18+2] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3]].z;
    
    ((float*)address)[blockIdx.x*18+3] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].x;
    ((float*)address)[blockIdx.x*18+4] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].y;
    ((float*)address)[blockIdx.x*18+5] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+1]].z;

    ((float*)address)[blockIdx.x*18+6] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].x;
    ((float*)address)[blockIdx.x*18+7] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].y;
    ((float*)address)[blockIdx.x*18+8] = (*mdl).vertices[(*mdl).faces[blockIdx.x*3+2]].z;*/

    passver[0].x = m.m[0][0] * passvert[0].x + m.m[0][1] * passvert[0].y + m.m[0][2] * passvert[0].z + m.m[0][3];
    passver[0].y = m.m[1][0] * passvert[0].x + m.m[1][1] * passvert[0].y + m.m[1][2] * passvert[0].z + m.m[1][3];
    passver[0].z = m.m[2][0] * passvert[0].x + m.m[2][1] * passvert[0].y + m.m[2][2] * passvert[0].z + m.m[2][3];

    passver[1].x = m.m[0][0] * passvert[1].x + m.m[0][1] * passvert[1].y + m.m[0][2] * passvert[1].z + m.m[0][3];
    passver[1].y = m.m[1][0] * passvert[1].x + m.m[1][1] * passvert[1].y + m.m[1][2] * passvert[1].z + m.m[1][3];
    passver[1].z = m.m[2][0] * passvert[1].x + m.m[2][1] * passvert[1].y + m.m[2][2] * passvert[1].z + m.m[2][3];

    passver[2].x = m.m[0][0] * passvert[2].x + m.m[0][1] * passvert[2].y + m.m[0][2] * passvert[2].z + m.m[0][3];
    passver[2].y = m.m[1][0] * passvert[2].x + m.m[1][1] * passvert[2].y + m.m[1][2] * passvert[2].z + m.m[1][3];
    passver[2].z = m.m[2][0] * passvert[2].x + m.m[2][1] * passvert[2].y + m.m[2][2] * passvert[2].z + m.m[2][3];

    /*((float*)address)[blockIdx.x*18+0+9] = passver[0].x;
    ((float*)address)[blockIdx.x*18+1+9] = passver[0].y;
    ((float*)address)[blockIdx.x*18+2+9] = passver[0].z;
    
    ((float*)address)[blockIdx.x*18+3+9] = passver[1].x;
    ((float*)address)[blockIdx.x*18+4+9] = passver[1].y;
    ((float*)address)[blockIdx.x*18+5+9] = passver[1].z;

    ((float*)address)[blockIdx.x*18+6+9] = passver[2].x;
    ((float*)address)[blockIdx.x*18+7+9] = passver[2].y;
    ((float*)address)[blockIdx.x*18+8+9] = passver[2].z;*/

    if(passvert[0].z!=0){
        passver[0].x = (passver[0].x/passver[0].z)*fovm + sw/2;
        passver[0].y = (passver[0].y/passver[0].z)*fovm + sh/2;
    }
    if(passvert[1].z!=0){
        passver[1].x = (passver[1].x/passver[1].z)*fovm + sw/2;
        passver[1].y = (passver[1].y/passver[1].z)*fovm + sh/2;
    }
    if(passver[2].z!=0){
        passver[2].x = (passver[2].x/passver[2].z)*fovm + sw/2;
        passver[2].y = (passver[2].y/passver[2].z)*fovm + sh/2;
    }

    u32 thx;
    u32 blx;
    if(abs(passver[1].x-passver[0].x)>abs(passver[1].y-passver[0].y)){
        thx = abs(passver[1].x-passver[0].x) +2;
    }else{
        thx = abs(passver[1].y-passver[0].y) +2;
    }
    if(abs(passver[2].x-passver[0].x)>abs(passver[2].y-passver[0].y)){
        blx = abs(passver[2].x-passver[0].x) +2;
    }else{
        blx = abs(passver[2].y-passver[0].y) +2;
    }
    triangle<<<blx, thx>>>(address, 
        {int(passver[0].x), int(passver[0].y), int((*mdl).uv[(*mdl).faces[blockIdx.x*3  ]*2]*255), int((*mdl).uv[(*mdl).faces[blockIdx.x*3  ]*2+1]*255), int(passver[0].z*1000000)},
        {int(passver[1].x), int(passver[1].y), int((*mdl).uv[(*mdl).faces[blockIdx.x*3+1]*2]*255), int((*mdl).uv[(*mdl).faces[blockIdx.x*3+1]*2+1]*255), int(passver[1].z*1000000)},
        {int(passver[2].x), int(passver[2].y), int((*mdl).uv[(*mdl).faces[blockIdx.x*3+2]*2]*255), int((*mdl).uv[(*mdl).faces[blockIdx.x*3+2]*2+1]*255), int(passver[2].z*1000000)},
        image, imgW, imgH, zbuffer);
}