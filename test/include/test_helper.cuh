#ifndef TEST_HELPER_H
#define TEST_HELPER_H

#include <cuda_runtime.h>

template <typename in_data_type, typename out_data_type, typename action_type>
__global__ void helper_kernel (
  const in_data_type *in,
  out_data_type *out,
  action_type action)
{
  action (in, out);
}

template <typename in_data_type, typename out_data_type, typename action_type>
void launch_kernel (
  dim3 grid,
  dim3 block,
  size_t data_size,
  const in_data_type *in,
  out_data_type *out,
  const action_type &action)
{
  in_data_type *d_in {};
  out_data_type *d_out {};

  cudaMalloc (&d_in, data_size * sizeof (in_data_type));
  cudaMalloc (&d_out, data_size * sizeof (out_data_type));

  cudaMemcpy (d_in, in, data_size * sizeof (in_data_type), cudaMemcpyHostToDevice);

  helper_kernel<<<grid, block>>> (d_in, d_out, action);

  cudaMemcpy (out, d_out, data_size * sizeof (out_data_type), cudaMemcpyDeviceToHost);

  cudaFree (d_out);
  cudaFree (d_in);
}

template <typename in_data_type, typename out_data_type, typename action_type>
void launch_kernel (
  dim3 grid,
  dim3 block,
  size_t in_data_size,
  size_t out_data_size,
  const in_data_type *in,
  out_data_type *out,
  const action_type &action)
{
  in_data_type *d_in {};
  out_data_type *d_out {};

  cudaMalloc (&d_in, in_data_size * sizeof (in_data_type));
  cudaMalloc (&d_out, out_data_size * sizeof (out_data_type));

  cudaMemcpy (d_in, in, in_data_size * sizeof (in_data_type), cudaMemcpyHostToDevice);

  helper_kernel<<<grid, block>>> (d_in, d_out, action);

  cudaMemcpy (out, d_out, out_data_size * sizeof (out_data_type), cudaMemcpyDeviceToHost);

  cudaFree (d_out);
  cudaFree (d_in);
}

class user_type
{
public:
  unsigned long long int x {};
  unsigned long long int y {};

public:
  __device__ __host__ user_type () {}
  explicit __device__ __host__ user_type (int i) : x (i), y (0ull) {}
  __device__ __host__ user_type (unsigned long long int x_arg, unsigned long long int y_arg) : x (x_arg), y (y_arg) {}

  friend bool operator !=(const user_type &lhs, const user_type &rhs)
  {
    return lhs.x != rhs.x || lhs.y != rhs.y;
  }

  friend __device__ user_type operator+ (const user_type &lhs, const user_type &rhs)
  {
    return user_type (lhs.x + rhs.x, lhs.y + rhs.y);
  }
};

#endif