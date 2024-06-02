#include <iostream>
#include "SDL2/SDL.h"
#pragma comment(lib, "winmm.lib")
#pragma comment (lib, "Setupapi.lib")
#pragma comment(lib, "imm32.lib")
#pragma comment(lib, "version.lib")
// 屏幕宽高
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

int wWinMain(int argc, char* args[]) {
    printf("Hello, SDL!\n");
    
    // 初始化 SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // 创建窗口
    SDL_Window* window = SDL_CreateWindow("SDL Demo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // 获取窗口表面
    SDL_Surface* screenSurface = SDL_GetWindowSurface(window);

    // 填充表面为白色
    SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0xFF, 0xFF));

    // 更新窗口表面
    SDL_UpdateWindowSurface(window);

    // 事件循环
    bool quit = false;
    SDL_Event e;
    while (!quit) {
        while (SDL_PollEvent(&e) != 0) {
            // 用户请求退出
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }

        // 延迟一段时间
        SDL_Delay(10);
    }

    // 销毁窗口
    SDL_DestroyWindow(window);

    // 退出 SDL
    SDL_Quit();

    return 0;
}
