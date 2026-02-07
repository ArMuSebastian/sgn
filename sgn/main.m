#define SOKOL_IMPL

#if defined(__APPLE__)
#include <TargetConditionals.h>

#define SOKOL_METAL

#elif defined(_WIN32)
// ----- Windows -----
//    #define SOKOL_D3D11
//    #define SOKOL_GLCORE
//    #define SOKOL_WGPU
//    #define SOKOL_NOAPI

#elif defined(__ANDROID__)
// ----- Android -----
//    #define SOKOL_GLES3

#elif defined(__EMSCRIPTEN__)
// ----- Emscripten -----
#define SOKOL_GLES3
//    #define SOKOL_WGPU

#elif defined(__linux__) || defined(__unix__)
// ----- Linux -----
//    #define SOKOL_GLCORE
//    #define SOKOL_GLES3
//    #define SOKOL_WGPU

#else
#error "Unknown platform for sokol renderer selection"
#endif


#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"
#include "sokol_log.h"
#include "sokol_gl.h"

static void init(void) {
  sg_setup(&(sg_desc){
    .environment = sglue_environment(),
    .logger.func = slog_func,
  });
  sgl_setup(&(sgl_desc_t){
    .logger.func = slog_func,
  });
}


static void frame(void) {
  sg_begin_pass(&(sg_pass){ .swapchain = sglue_swapchain() });

  int w = sapp_width();
  int h = sapp_height();
  int o = 50;

  sgl_matrix_mode_projection();
  sgl_load_identity();
  sgl_ortho(0.0f, (float)w, (float)h, 0.0f, -1.0f, 1.0f);

  sgl_matrix_mode_modelview();
  sgl_load_identity();

  const float radius = ((float)(w < h ? w : h)) / 2.0f;
  const float cx = (float)w / 2.0f;
  const float cy = (float)h / 2.0f;
  const int segments = 64;

  sgl_c4f(1.0f, 0.6f, 0.2f, 1.0f);
  sgl_scissor_rectf((float)o, (float)o, (float)(w - o * 2), (float)(h - o * 2), true);

  sgl_begin_triangles();
  for (int i = 0; i < segments; i++) {
    float a0 = 2.0f * 3.14159265359f * i / segments;
    float a1 = 2.0f * 3.14159265359f * (i + 1) / segments;

    float x0 = cx + cosf(a0) * radius;
    float y0 = cy + sinf(a0) * radius;
    float x1 = cx + cosf(a1) * radius;
    float y1 = cy + sinf(a1) * radius;

    sgl_v2f(cx, cy);
    sgl_v2f(x0, y0);
    sgl_v2f(x1, y1);
  }
  sgl_end();

  sgl_draw();

  sg_end_pass();
  sg_commit();
}

static void cleanup(void) {
  sgl_shutdown();
  sg_shutdown();
}

sapp_desc sokol_main(int argc, char **argv) {
  return (sapp_desc){
    .init_cb = init,
    .frame_cb = frame,
    .cleanup_cb = cleanup,
    .width = 1200,
    .height = 600,
    .high_dpi = true,
    .icon.sokol_default = true,
    .logger.func = slog_func,
  };
}

