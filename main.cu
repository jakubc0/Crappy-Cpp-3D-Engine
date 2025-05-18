#include "stuff.cu"
#include "window.cu"
#include "render.cu"
#include "stdio.h"
using namespace std;

// COMPILER COMMAND: cd "${workspaceFolder}" ; if ($?) {nvcc main.cu -o main -O3 -lGdi32 -luser32 -rdc=true} ; if ($?) { .\main }

/*[==========================HISTORY==========================]
  |                                                           |
  |   Started around november 3rd 2023.                       |
  |   On ~december 4th this engine was capable of:            |
  |    - Drawing textured triangles.                          |
  |    - Drawing textured/untextured rectangles.              |
  |    - Drawing straight lines of a given color.             |
  |    - Filling the screen with a given color.               |
  |                                                           |
  |   On march 11th 2025 I learned to use NVIDIA CUDA.        |
  |   On march 12th 2025 I finally uploaded this to github.   |
  |   On march 16th 2025 I "converted" this project to CUDA.  |
  |                                                           |
  |   May 17th - "model" rendering (took very long)           |
  |                                                           |
  |   PLANS:                                                  |
  |                                                           |
  |                                                           |
*///==========================================================]

int main() {
    wiindow* window = new wiindow();
    HDC hdc = GetDC(ehwnd);

    bool running = true;
    unsigned int *gpuscr = 0;
    unsigned int *zbuffr = 0;
    cudaMalloc(&gpuscr, size_t(sizeof(unsigned int)*bwidth*bheight));
    cudaMalloc(&zbuffr, size_t(sizeof(unsigned int)*bwidth*bheight));
    cudaMemcpy(gpuscr, buffermem, size_t(sizeof(unsigned int)*bwidth*bheight), cudaMemcpyHostToDevice);
    unsigned int* grassimage = uploadToGPU(grass);

    vertex* cvx = 0;
    u32* ctr = 0;
    float* cuv = 0;
    
    vertex vvxx[8] = {
        {-1, -1, -1}, {-1, -1, 1},
        {-1,  1, -1}, {-1,  1, 1},
        { 1, -1, -1}, { 1, -1, 1},
        { 1,  1, -1}, { 1,  1, 1}
    };
    u32 ttrr[12*3] = {
        0, 1, 2,  1, 2, 3,
        2, 3, 6,  3, 6, 7,
        4, 5, 6,  5, 6, 7,
        0, 1, 4,  1, 4, 5,
        0, 2, 4,  2, 4, 6,
        1, 3, 5,  3, 5, 7
    };
    float uuvv[8*2] = {
        0, 0,  1, 0,
        0, 1,  1, 1,
        1, 0,  0, 0,
        1, 1,  0, 1
    };
    cudaMalloc(&cvx, size_t(sizeof(vertex)*8));
    cudaMalloc(&ctr, size_t(sizeof(u32)*12*3));
    cudaMalloc(&cuv, size_t(sizeof(float)*8*2));
    cudaMemcpy(cvx, vvxx, size_t(sizeof(vertex)*8), cudaMemcpyHostToDevice);
    cudaMemcpy(ctr, ttrr, size_t(sizeof(u32)*12*3), cudaMemcpyHostToDevice);
    cudaMemcpy(cuv, uuvv, size_t(sizeof(float)*8*2),cudaMemcpyHostToDevice);
    model tri = {cvx, ctr, cuv};
    model *tttttt =0;
    cudaMalloc(&tttttt, sizeof(model));
    cudaMemcpy(tttttt, &tri, sizeof(model), cudaMemcpyHostToDevice);

    double theta = 0;
    matrix rot = {float(std::cos(theta)), 0, float(std::sin(theta)), 0, 0, 1, 0, 0, -float(std::sin(theta)), 0, float(std::cos(theta)), 0, 0, 0, 0, 1};
    matrix pos = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 3, 0, 0, 0, 1};

    while (running){
        if (!window->ProcessMessages()){
            running = false;
        }
        rot = {float(std::cos(theta)), 0, float(std::sin(theta)), 0, 0, 1, 0, 0, -float(std::sin(theta)), 0, float(std::cos(theta)), 0, 0, 0, 0, 1};
        clearRect<<<bwidth, bheight>>>(gpuscr, 0x303030, 0, 0);
        clearRect<<<bwidth, bheight>>>(zbuffr, 0xffffffff, 0, 0);
        /*for(int j=0;j<12;j++) {for(int i=0;i<18;i++){
            string a = to_string(floor((((float*)buffermem)[i+j*18])*1000)/1000) + "      ";
            string b = "      ";
            for(int ii=0;ii<6;ii++){
                b[ii] = a[ii];
            }
            cout << b << " "; if(i%3==2) cout << " ";
        } cout << "\n";}cout << "\n";*/
        mdraw<<<12, 1>>>(gpuscr, mulm(pos, rot), tttttt, grassimage, 16, 16, bwidth, bheight, 100, zbuffr);
        cudaMemcpy(buffermem, gpuscr, size_t(sizeof(unsigned int)*bwidth*bheight), cudaMemcpyDeviceToHost);
        StretchDIBits(hdc, 0, 0, bwidth, bheight, 0, 0, bwidth, bheight, buffermem, &bufbitinf, DIB_RGB_COLORS, SRCCOPY);
        theta+=0.05;
        Sleep(10);
    }
    delete window;
    return 0;
}