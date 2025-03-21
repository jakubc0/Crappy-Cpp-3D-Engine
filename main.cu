#include "stuff.cu"
#include "window.cu"
#include "render.cu"
#include "stdio.h"
using namespace std;

// COMPILER COMMAND: cd "${workspaceFolder}" ; if ($?) {nvcc main.cu -o main -lGdi32 -luser32} ; if ($?) { .\main }

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
  |   On match 16th 2025 I "converted" this project to CUDA.  |
  |                                                           |
  |   PLANS:                                                  |
  |    - Make this engine run on a GPU.                       |
  |                                                           |
*///==========================================================]

int main() {
    wiindow* window = new wiindow();
    HDC hdc = GetDC(ehwnd);

    bool running = true;
    unsigned int *gpuscr = 0;
    cudaMalloc(&gpuscr, size_t(sizeof(unsigned int)*bwidth*bheight));
    cudaMemcpy(gpuscr, buffermem, size_t(sizeof(unsigned int)*bwidth*bheight), cudaMemcpyHostToDevice);

    while (running){
        if (!window->ProcessMessages()){
            running = false;
        }

        clrscr<<<bwidth, bheight>>>(gpuscr, 0x0000ff);
        cudaMemcpy(buffermem, gpuscr, size_t(sizeof(unsigned int)*bwidth*bheight), cudaMemcpyDeviceToHost);
        StretchDIBits(hdc, 0, 0, bwidth, bheight, 0, 0, bwidth, bheight, buffermem, &bufbitinf, DIB_RGB_COLORS, SRCCOPY);
    }
    delete window;
    return 0;
}