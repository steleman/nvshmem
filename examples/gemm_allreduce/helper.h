#pragma once

#include <cuda.h>
#include <cuda_profiler_api.h>
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <nvshmem.h>
#include <iostream>
#include <cstdio>
#include "helper_timer.h"

#ifndef CUDA_CHECK
#define CUDA_CHECK(stmt)                                                    \
  do {                                                                      \
    cudaError_t result = (stmt);                                            \
    if (cudaSuccess != result) {                                            \
      fprintf(stderr, "[%s:%d]: CUDA failed with %s\n", __FILE__, __LINE__, \
              cudaGetErrorString(result));                                  \
      exit(EXIT_FAILURE);                                                   \
    }                                                                       \
    assert(cudaSuccess == result);                                          \
  } while (0)
#endif

#ifndef CUTLASS_CHECK
#define CUTLASS_CHECK(status)                                               \
  do {                                                                      \
    cutlass::Status error = (status);                                       \
    if (error != cutlass::Status::kSuccess) {                               \
      fprintf(stderr, "[%s:%d]: CUTLASS error: %s\n", __FILE__, __LINE__,   \
              cutlassGetStatusString(error));                               \
      exit(EXIT_FAILURE);                                                   \
    }                                                                       \
  } while (0)
#endif

class GpuTimer {
private:
  GpuTimer(const GpuTimer& rhs) = delete;
  GpuTimer& operator=(const GpuTimer& rhs) = delete;

private:
  StopWatchInterface* timer;

public:
  GpuTimer() : timer(nullptr) {
    (void) sdkCreateTimer(&timer);
    (void) sdkResetTimer(&timer);
  }

  ~GpuTimer() {
    (void) sdkDeleteTimer(&timer);
  }

  void start() {
    (void) sdkStartTimer(&timer);
  }

  void stop() {
    (void) sdkStopTimer(&timer);
  }

  float elapsed_millis() {
    return sdkGetTimerValue(&timer);
  }
};

