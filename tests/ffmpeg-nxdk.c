#include <libavcodec/avcodec.h>
#include <libswresample/swresample.h>
#include <libswscale/swscale.h>

/* Exercise the installed API surface and resolve all decoder and runtime symbols at link time. */
int main(void) {
  AVCodecParserContext *parser = av_parser_init(AV_CODEC_ID_H264);
  struct SwsContext *scaler = sws_getContext(16, 16, AV_PIX_FMT_YUV420P, 16, 16, AV_PIX_FMT_BGRA, SWS_BILINEAR, NULL, NULL, NULL);
  SwrContext *resampler = swr_alloc();
  int available = parser && scaler && resampler && avcodec_find_decoder(AV_CODEC_ID_H264) &&
                  avcodec_find_decoder(AV_CODEC_ID_H263) && avcodec_find_decoder(AV_CODEC_ID_H263I) &&
                  avcodec_find_decoder(AV_CODEC_ID_H263P) && avcodec_find_decoder(AV_CODEC_ID_MPEG2VIDEO) &&
                  avcodec_find_decoder(AV_CODEC_ID_OPUS);
  av_parser_close(parser);
  sws_freeContext(scaler);
  swr_free(&resampler);
  return available ? 0 : 1;
}
