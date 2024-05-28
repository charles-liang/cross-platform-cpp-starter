#include <iostream>
#include "SDL2/SDL.h"
#include "SDL2/SDL_syswm.h"
int main(int argc, char* argv[]) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize. SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

    const int width = 800;
    const int height = 600;
    SDL_Window* window = SDL_CreateWindow(
        argv[0], SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width,
        height, SDL_WINDOW_SHOWN);

    if (window == nullptr) {
        printf("Window could not be created. SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

// #if !BX_PLATFORM_EMSCRIPTEN
    SDL_SysWMinfo wmi;
    SDL_VERSION(&wmi.version);
    if (!SDL_GetWindowWMInfo(window, &wmi)) {
        printf(
            "SDL_SysWMinfo could not be retrieved. SDL_Error: %s\n",
            SDL_GetError());
        return 1;
    }
//     bgfx::renderFrame(); // single threaded mode
// #endif // !BX_PLATFORM_EMSCRIPTEN

//     bgfx::PlatformData pd{};
// #if BX_PLATFORM_WINDOWS
//     pd.nwh = wmi.info.win.window;
// #elif BX_PLATFORM_OSX
//     pd.nwh = wmi.info.cocoa.window;
// #elif BX_PLATFORM_IOS
//     pd.ndt = wmi.info.uikit.viewController;
//     pd.nwh = wmi.info.uikit.window;
// #elif BX_PLATFORM_LINUX
//     pd.ndt = wmi.info.x11.display;
//     pd.nwh = (void*)(uintptr_t)wmi.info.x11.window;
// #elif BX_PLATFORM_EMSCRIPTEN
//     pd.nwh = (void*)"#canvas";
// #endif // BX_PLATFORM_WINDOWS ? BX_PLATFORM_OSX ? BX_PLATFORM_LINUX ?
//        // BX_PLATFORM_EMSCRIPTEN

//     bgfx::Init bgfx_init;
//     bgfx_init.type = bgfx::RendererType::Count; // auto choose renderer
//     bgfx_init.resolution.width = width;
//     bgfx_init.resolution.height = height;
//     bgfx_init.resolution.reset = BGFX_RESET_VSYNC;
//     bgfx_init.platformData = pd;
//     bgfx::init(bgfx_init);

//     bgfx::setViewClear(
//         0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x6495EDFF, 1.0f, 0);
//     bgfx::setViewRect(0, 0, 0, width, height);

//     ImGui::CreateContext();

//     ImGui_Implbgfx_Init(255);
// #if BX_PLATFORM_WINDOWS
//     ImGui_ImplSDL2_InitForD3D(window);
// #elif BX_PLATFORM_OSX
//     ImGui_ImplSDL2_InitForMetal(window);
// #elif BX_PLATFORM_LINUX || BX_PLATFORM_EMSCRIPTEN
//     ImGui_ImplSDL2_InitForOpenGL(window, nullptr);
// #endif // BX_PLATFORM_WINDOWS ? BX_PLATFORM_OSX ? BX_PLATFORM_LINUX ?
//        // BX_PLATFORM_EMSCRIPTEN

//     bgfx::VertexLayout pos_col_vert_layout;
//     pos_col_vert_layout.begin()
//         .add(bgfx::Attrib::Position, 3, bgfx::AttribType::Float)
//         .add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
//         .end();
//     bgfx::VertexBufferHandle vbh = bgfx::createVertexBuffer(
//         bgfx::makeRef(cube_vertices, sizeof(cube_vertices)),
//         pos_col_vert_layout);
//     bgfx::IndexBufferHandle ibh = bgfx::createIndexBuffer(
//         bgfx::makeRef(cube_tri_list, sizeof(cube_tri_list)));

//     const std::string shader_root =
// #if BX_PLATFORM_EMSCRIPTEN
//         "shader/embuild/";
// #else
//         "shader/build/";
// #endif // BX_PLATFORM_EMSCRIPTEN

//     std::string vshader;
//     if (!fileops::read_file(shader_root + "v_simple.bin", vshader)) {
//         printf("Could not find shader vertex shader (ensure shaders have been "
//                "compiled).\n"
//                "Run compile-shaders-<platform>.sh/bat\n");
//         return 1;
//     }

//     std::string fshader;
//     if (!fileops::read_file(shader_root + "f_simple.bin", fshader)) {
//         printf("Could not find shader fragment shader (ensure shaders have "
//                "been compiled).\n"
//                "Run compile-shaders-<platform>.sh/bat\n");
//         return 1;
//     }

//     bgfx::ShaderHandle vsh = create_shader(vshader, "vshader");
//     bgfx::ShaderHandle fsh = create_shader(fshader, "fshader");
//     bgfx::ProgramHandle program = bgfx::createProgram(vsh, fsh, true);

//     context_t context;
//     context.width = width;
//     context.height = height;
//     context.program = program;
//     context.window = window;
//     context.vbh = vbh;
//     context.ibh = ibh;

// #if BX_PLATFORM_EMSCRIPTEN
//     emscripten_set_main_loop_arg(main_loop, &context, -1, 1);
// #else
//     while (!context.quit) {
//         main_loop(&context);
//     }
// #endif // BX_PLATFORM_EMSCRIPTEN

//     bgfx::destroy(vbh);
//     bgfx::destroy(ibh);
//     bgfx::destroy(program);

//     ImGui_ImplSDL2_Shutdown();
//     ImGui_Implbgfx_Shutdown();

//     ImGui::DestroyContext();
//     bgfx::shutdown();
    printf("Exiting cleanly\n");
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
