#include <stdio.h>

#include <libavcodec/avcodec.h>
#include <libavcodec/cbs.h>
#include <opus/opus.h>

int main(void) {
    CodedBitstreamContext *bitstream = NULL;
    if (ff_cbs_init(&bitstream, AV_CODEC_ID_H264, NULL) < 0) {
        fprintf(stderr, "Could not initialize Sunshine's CBS helper\n");
        return 1;
    }
    ff_cbs_close(&bitstream);
    const enum AVCodecID codecs[] = {AV_CODEC_ID_H264, AV_CODEC_ID_HEVC, AV_CODEC_ID_AV1};
    for (unsigned int i = 0; i < sizeof(codecs) / sizeof(codecs[0]); ++i) {
        const AVCodec *codec = avcodec_find_decoder(codecs[i]);
        AVCodecContext *context = codec ? avcodec_alloc_context3(codec) : NULL;
        if (!context || avcodec_open2(context, codec, NULL) < 0) {
            fprintf(stderr, "Could not initialize decoder %u\n", i);
            avcodec_free_context(&context);
            return 1;
        }
        printf("Initialized %s\n", codec->name);
        avcodec_free_context(&context);
    }
    int error;
    OpusDecoder *opus = opus_decoder_create(48000, 2, &error);
    if (!opus || error != OPUS_OK) {
        fprintf(stderr, "Could not initialize Opus decoder\n");
        return 1;
    }
    opus_decoder_destroy(opus);
    return 0;
}
