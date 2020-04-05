//
// Created by egi on 4/4/20.
//

#ifndef CULIB_SCAN_H
#define CULIB_SCAN_H

#include <type_traits>

#include "culib/warp/detail/warp_scan.cuh"

namespace culib
{
namespace warp
{

template<typename T, typename... Rest>
struct is_any : std::false_type {};

template<typename T, typename First>
struct is_any<T, First> : std::is_same<T, First> {};

template<typename T, typename First, typename... Rest>
struct is_any<T, First, Rest...> : std::integral_constant<bool, std::is_same<T, First>::value || is_any<T, Rest...>::value>
{};

template <int required_cc>
constexpr bool check_compute_capability ()
{
#if defined(__CUDA_ARCH__)
  return __CUDA_ARCH__ >= required_cc;
#else
  return false;
#endif
}

/**
* @brief Class for parallel scan within warp
*
* Scan uses a binary combining operator to compute a single aggregate from an array of elements. The
* number of entrant threads must be equal to warpSize.
* The default binary combining operator is the sum.
*
* @tparam _Tp Scanned data type
* @tparam _ReducePolicy Policy for warp threads data exchange
*/
template<
  typename data_type,
  typename scan_policy = typename std::conditional<
    std::integral_constant<bool, is_any<data_type,
        int,
        long,
        long long,
        unsigned int,
        unsigned long,
        unsigned long long,
        float,
        double>::value
      && check_compute_capability<300> ()>::value,
    detail::warp_shfl_scan<data_type>,
    detail::warp_shrd_scan<data_type>>::type>
class scan : public scan_policy {
public:
  using scan_policy::scan_policy;

  /**
   * @tparam _BinaryOperation Binary combining function object thata will be applied in unspecified order.
   *                          The behaviour is undefined if _BinaryOperation modifies any element.
   */
  template<typename binary_operation = detail::default_scan_binary_op<data_type>>
  __device__ inline data_type
  operator ()(data_type val, binary_operation binary_op = {})
  {
    return scan_value (val, binary_op);
  }
};

} // warp
} // culib

#endif //CULIB_SCAN_H