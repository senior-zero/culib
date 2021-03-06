//
// Created by egi on 4/5/20.
//

#ifndef CULIB_VERSION_H
#define CULIB_VERSION_H

namespace culib
{
namespace cuda
{

template<int required_cc>
__device__ constexpr bool check_compute_capability ()
{
#if defined(__CUDA_ARCH__)
  return __CUDA_ARCH__ >= required_cc;
#else
  return false;
#endif
}

} // utils
} //culib

#endif //CULIB_VERSION_H
