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

__global__ void clrscr(unsigned int* address, unsigned int color){
    unsigned int* pixel = address+blockIdx.x+threadIdx.x*640;
    *pixel = color;
}
// the drawing file