#pragma once
#include <Windows.h>
#include "stuff.cu"
#include "buttons.cu"
void* buffermem;
int bwidth;
int bheight;
bool keyW, keyA, keyS, keyD;
float deltatime = 0.016666f;
float performance_frequency;
typedef struct
{
    BITMAPFILEHEADER Header;
    BITMAPINFO Info;
    unsigned char* Pixels;
} BITMAPDATA;
HWND ehwnd;
BITMAPINFO bufbitinf;
Input input = {};
LRESULT CALLBACK WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
class wiindow{
public:
    wiindow();
    wiindow(const wiindow&) = delete;
    wiindow& operator =(const wiindow&) = delete;
    ~wiindow();
    bool ProcessMessages();
    int pox = 640;
    int poy = 300;
    int wid = 640;
    int hgh = 480;
private:
    HINSTANCE m_hInstance;
    HWND m_hWnd;
};
LRESULT CALLBACK WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam){
    switch (uMsg){
    case WM_CLOSE:
        DestroyWindow(hWnd);
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    case WM_SIZE:
        RECT rect;
        GetClientRect(hWnd, &rect);
        bwidth = rect.right - rect.left;
        bheight = rect.bottom - rect.top;
        int buffer_size = bwidth * bheight * sizeof(unsigned int);
        if (buffermem) VirtualFree(buffermem, 0, MEM_RELEASE);
        buffermem = VirtualAlloc(0, buffer_size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
        bufbitinf.bmiHeader.biSize = sizeof(bufbitinf.bmiHeader);
        bufbitinf.bmiHeader.biWidth = bwidth;
        bufbitinf.bmiHeader.biHeight = -bheight;
        bufbitinf.bmiHeader.biPlanes = 1;
        bufbitinf.bmiHeader.biBitCount = 32;
        bufbitinf.bmiHeader.biCompression = BI_RGB;
    }
    return DefWindowProc(hWnd, uMsg, wParam, lParam);};
wiindow::wiindow(): m_hInstance(GetModuleHandle(nullptr)){
    LPCSTR CLASS_NAME = "window";
    WNDCLASS wndClass = {};
    wndClass.lpszClassName = CLASS_NAME;
    wndClass.hInstance = m_hInstance;
    wndClass.hIcon = LoadIcon(NULL, IDI_WINLOGO);
    wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndClass.lpfnWndProc = WindowProc;
    RegisterClass(&wndClass);
    DWORD style = WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU;
    RECT rect;
    rect.left = pox;
    rect.top = poy;
    rect.right = rect.left + wid;
    rect.bottom = rect.top + hgh;
    AdjustWindowRect(&rect, style, false);
    m_hWnd = CreateWindowEx(0, CLASS_NAME, "Crappy C++ 3D Engine", style, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, NULL, NULL, m_hInstance, NULL);
    ehwnd = m_hWnd;
    ShowWindow(m_hWnd, SW_SHOW);}
wiindow::~wiindow(){
    LPCSTR CLASS_NAME = "window";
    UnregisterClass(CLASS_NAME, m_hInstance);}
bool wiindow::ProcessMessages(){
    MSG msg = {};
    while (PeekMessage(&msg, nullptr, 0u, 0u, PM_REMOVE)){
        switch (msg.message){
            case WM_KEYUP:
            case WM_KEYDOWN:{
                u32 vk_code = (u32)msg.wParam;
                bool is_down = ((msg.lParam & (1 << 31)) == 0);
                switch(vk_code){
                    case 0x57: {
                        input.buttons[BUTTON_W].is_down = is_down;
                        input.buttons[BUTTON_W].changed = true;
                    }break;
                    case 0x41: {
                        input.buttons[BUTTON_A].is_down = is_down;
                        input.buttons[BUTTON_A].changed = true;
                    }break;
                    case 0x53: {
                        input.buttons[BUTTON_S].is_down = is_down;
                        input.buttons[BUTTON_S].changed = true;
                    }break;
                    case 0x44: {
                        input.buttons[BUTTON_D].is_down = is_down;
                        input.buttons[BUTTON_D].changed = true;
                    }break;
                }
                break;
            }
            case WM_QUIT:
                return false;
                break;
            default:
                TranslateMessage(&msg);
                DispatchMessage(&msg);
        }
    }
    keyW = input.buttons[BUTTON_W].is_down;
    keyA = input.buttons[BUTTON_A].is_down;
    keyS = input.buttons[BUTTON_S].is_down;
    keyD = input.buttons[BUTTON_D].is_down;
    return true;}