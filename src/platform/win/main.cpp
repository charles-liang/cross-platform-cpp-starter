#pragma comment(lib, "winmm.lib")
#pragma comment (lib, "Setupapi.lib")
#pragma comment(lib, "imm32.lib")
#pragma comment(lib, "version.lib")
// 屏幕宽高
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
}

#include "SDL2/SDL.h"

#include <iostream>

void showErrorAndExit(const char* message) {
    std::cerr << message << std::endl;
    exit(1);
}

int wWinMain(int argc, char* args[]) {
    printf("Hello, SDL!\n");
    
    if (argc < 2) {
        showErrorAndExit("Usage: ./helloworld <video_file>");
    
    }
    av_register_all();

    AVFormatContext* pFormatCtx = avformat_alloc_context();
    if (avformat_open_input(&pFormatCtx, argv[1], nullptr, nullptr) != 0) {
        showErrorAndExit("Couldn't open video file.");
    }

    if (avformat_find_stream_info(pFormatCtx, nullptr) < 0) {
        showErrorAndExit("Couldn't find stream information.");
    }


        int videoStreamIndex = -1;
    for (unsigned int i = 0; i < pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStreamIndex = i;
            break;
        }
    }
    if (videoStreamIndex == -1) {
        showErrorAndExit("Didn't find a video stream.");
    }

    AVCodecParameters* pCodecParams = pFormatCtx->streams[videoStreamIndex]->codecpar;
    AVCodec* pCodec = avcodec_find_decoder(pCodecParams->codec_id);
    if (pCodec == nullptr) {
        showErrorAndExit("Unsupported codec!");
    }

    AVCodecContext* pCodecCtx = avcodec_alloc_context3(pCodec);
    if (avcodec_parameters_to_context(pCodecCtx, pCodecParams) < 0) {
        showErrorAndExit("Couldn't copy codec parameters to codec context.");
    }

    if (avcodec_open2(pCodecCtx, pCodec, nullptr) < 0) {
        showErrorAndExit("Couldn't open codec.");
    }




    // 初始化 SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // 创建窗口
    SDL_Window* window = SDL_CreateWindow("SDL Demo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, pCodecCtx->width,
                                          pCodecCtx->height, SDL_WINDOW_SHOWN);
    if (window == NULL) {
        showErrorAndExit("Couldn't create SDL window.");
        SDL_Quit();
        return 1;
    }

    // 获取窗口表面
    SDL_Surface* screenSurface = SDL_GetWindowSurface(window);

    // 填充表面为白色
    SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0xFF, 0xFF));

    // 更新窗口表面
    SDL_UpdateWindowSurface(window);

    // // 事件循环
    // bool quit = false;
    // SDL_Event e;
    // while (!quit) {
    //     while (SDL_PollEvent(&e) != 0) {
    //         // 用户请求退出
    //         if (e.type == SDL_QUIT) {
    //             quit = true;
    //         }
    //     }

    //     // 延迟一段时间
    //     SDL_Delay(10);
    // }

    AVFrame* pFrame = av_frame_alloc();
    AVFrame* pFrameYUV = av_frame_alloc();
    uint8_t* buffer = (uint8_t*)av_malloc(av_image_get_buffer_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height, 1));
    av_image_fill_arrays(pFrameYUV->data, pFrameYUV->linesize, buffer, AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height, 1);

    struct SwsContext* sws_ctx = sws_getContext(pCodecCtx->width,
                                                pCodecCtx->height,
                                                pCodecCtx->pix_fmt,
                                                pCodecCtx->width,
                                                pCodecCtx->height,
                                                AV_PIX_FMT_YUV420P,
                                                SWS_BILINEAR,
                                                nullptr,
                                                nullptr,
                                                nullptr);

    AVPacket packet;
    while (av_read_frame(pFormatCtx, &packet) >= 0) {
        if (packet.stream_index == videoStreamIndex) {
            if (avcodec_send_packet(pCodecCtx, &packet) == 0) {
                while (avcodec_receive_frame(pCodecCtx, pFrame) == 0) {
                    sws_scale(sws_ctx, (uint8_t const* const*)pFrame->data,
                              pFrame->linesize, 0, pCodecCtx->height,
                              pFrameYUV->data, pFrameYUV->linesize);

                    SDL_UpdateYUVTexture(texture, nullptr,
                                         pFrameYUV->data[0], pFrameYUV->linesize[0],
                                         pFrameYUV->data[1], pFrameYUV->linesize[1],
                                         pFrameYUV->data[2], pFrameYUV->linesize[2]);

                    SDL_RenderClear(renderer);
                    SDL_RenderCopy(renderer, texture, nullptr, nullptr);
                    SDL_RenderPresent(renderer);
                }
            }
        }
        av_packet_unref(&packet);
        SDL_Event event;
        SDL_PollEvent(&event);
        if (event.type == SDL_QUIT) {
            break;
        }
    }

    av_free(buffer);
    av_frame_free(&pFrame);
    av_frame_free(&pFrameYUV);
    sws_freeContext(sws_ctx);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();


    return 0;
}
