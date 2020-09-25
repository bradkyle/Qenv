#pragma once

// @generated by aten/src/ATen/gen.py from TypeDerived.h

#include <c10/core/TensorOptions.h>
#include <c10/core/Scalar.h>
#include <c10/core/QScheme.h>
#include <c10/core/MemoryFormat.h>
#include <c10/util/ArrayRef.h>
#include <c10/util/intrusive_ptr.h>
#include <torch/csrc/WindowsTorchApiMacro.h>
#include <ATen/Dimname.h>



namespace c10 {
struct Storage;
}

namespace at {

class Tensor;
using TensorList = ArrayRef<Tensor>;

class Context;
struct Generator;

struct Quantizer;
// This is temporary typedef to enable Quantizer in aten native function API
// we'll remove them when we are actually exposing Quantizer class
// to frontend
using ConstQuantizerPtr = const c10::intrusive_ptr<Quantizer>&;

namespace QuantizedCPUType {
  Tensor as_strided(const Tensor & self, IntArrayRef size, IntArrayRef stride, c10::optional<int64_t> storage_offset);
  Tensor quantized_batch_norm(const Tensor & input, const Tensor & weight, const Tensor & bias, const Tensor & mean, const Tensor & var, double eps, double output_scale, int64_t output_zero_point);
  Tensor clamp(const Tensor & self, c10::optional<Scalar> min, c10::optional<Scalar> max);
  Tensor _empty_affine_quantized(IntArrayRef size, const TensorOptions & options, double scale, int64_t zero_point, c10::optional<MemoryFormat> memory_format);
  Tensor _empty_per_channel_affine_quantized(IntArrayRef size, const Tensor & scales, const Tensor & zero_points, int64_t axis, const TensorOptions & options, c10::optional<MemoryFormat> memory_format);
  Tensor & resize_(Tensor & self, IntArrayRef size, c10::optional<MemoryFormat> memory_format);
  Tensor empty_quantized(IntArrayRef size, const Tensor & qtensor);
  Tensor quantized_max_pool2d(const Tensor & self, IntArrayRef kernel_size, IntArrayRef stride, IntArrayRef padding, IntArrayRef dilation, bool ceil_mode);
  Tensor mean(const Tensor & self, c10::optional<ScalarType> dtype);
  Tensor mean_dim(const Tensor & self, IntArrayRef dim, bool keepdim, c10::optional<ScalarType> dtype);
  Tensor & mean_out_out(Tensor & out, const Tensor & self, IntArrayRef dim, bool keepdim, c10::optional<ScalarType> dtype);
  Tensor channel_shuffle(const Tensor & self, int64_t groups);
  Tensor relu(const Tensor & self);
  Tensor & relu_(Tensor & self);
  Tensor sigmoid(const Tensor & self);
  Tensor tanh(const Tensor & self);
  Tensor threshold(const Tensor & self, Scalar threshold, Scalar value);
  Tensor clone(const Tensor & self, c10::optional<MemoryFormat> memory_format);
  Tensor dequantize_self(const Tensor & self);
  std::vector<Tensor> dequantize_tensors(TensorList tensors);
  double q_scale(const Tensor & self);
  int64_t q_zero_point(const Tensor & self);
  Tensor q_per_channel_scales(const Tensor & self);
  Tensor q_per_channel_zero_points(const Tensor & self);
  int64_t q_per_channel_axis(const Tensor & self);
  Tensor int_repr(const Tensor & self);
  QScheme qscheme(const Tensor & self);
  Tensor & set__source_Storage_storage_offset(Tensor & self, Storage source, int64_t storage_offset, IntArrayRef size, IntArrayRef stride);
  Tensor & set_quantizer_(Tensor & self, ConstQuantizerPtr quantizer);
  Tensor view(const Tensor & self, IntArrayRef size);
  Tensor & ne_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor ne_Scalar(const Tensor & self, Scalar other);
  Tensor & ne_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor ne_Tensor(const Tensor & self, const Tensor & other);
  Tensor & eq_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor eq_Scalar(const Tensor & self, Scalar other);
  Tensor & eq_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor eq_Tensor(const Tensor & self, const Tensor & other);
  Tensor & ge_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor ge_Scalar(const Tensor & self, Scalar other);
  Tensor & ge_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor ge_Tensor(const Tensor & self, const Tensor & other);
  Tensor & le_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor le_Scalar(const Tensor & self, Scalar other);
  Tensor & le_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor le_Tensor(const Tensor & self, const Tensor & other);
  Tensor & gt_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor gt_Scalar(const Tensor & self, Scalar other);
  Tensor & gt_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor gt_Tensor(const Tensor & self, const Tensor & other);
  Tensor & lt_out_Scalar_out(Tensor & out, const Tensor & self, Scalar other);
  Tensor lt_Scalar(const Tensor & self, Scalar other);
  Tensor & lt_out_Tensor_out(Tensor & out, const Tensor & self, const Tensor & other);
  Tensor lt_Tensor(const Tensor & self, const Tensor & other);
  Tensor min(const Tensor & self);
  Tensor max(const Tensor & self);
  std::tuple<Tensor,Tensor> sort(const Tensor & self, int64_t dim, bool descending);
  std::tuple<Tensor,Tensor> topk(const Tensor & self, int64_t k, int64_t dim, bool largest, bool sorted);
  Tensor unfold(const Tensor & self, int64_t dimension, int64_t size, int64_t step);
  bool equal(const Tensor & self, const Tensor & other);
  Tensor _cat(TensorList tensors, int64_t dim);
  Tensor & _cat_out_out(Tensor & out, TensorList tensors, int64_t dim);
  Tensor hardsigmoid(const Tensor & self);
  Tensor & hardtanh_out_out(Tensor & out, const Tensor & self, Scalar min_val, Scalar max_val);
  Tensor hardtanh(const Tensor & self, Scalar min_val, Scalar max_val);
  Tensor & hardtanh_(Tensor & self, Scalar min_val, Scalar max_val);
  Tensor & leaky_relu_out_out(Tensor & out, const Tensor & self, Scalar negative_slope);
  Tensor leaky_relu(const Tensor & self, Scalar negative_slope);
  Tensor & leaky_relu_(Tensor & self, Scalar negative_slope);
  Tensor _adaptive_avg_pool2d(const Tensor & self, IntArrayRef output_size);
  Tensor & adaptive_avg_pool3d_out_out(Tensor & out, const Tensor & self, IntArrayRef output_size);
  Tensor adaptive_avg_pool3d(const Tensor & self, IntArrayRef output_size);
  Tensor avg_pool2d(const Tensor & self, IntArrayRef kernel_size, IntArrayRef stride, IntArrayRef padding, bool ceil_mode, bool count_include_pad, c10::optional<int64_t> divisor_override);
  Tensor avg_pool3d(const Tensor & self, IntArrayRef kernel_size, IntArrayRef stride, IntArrayRef padding, bool ceil_mode, bool count_include_pad, c10::optional<int64_t> divisor_override);
  Tensor reflection_pad1d(const Tensor & self, IntArrayRef padding);
  Tensor upsample_bilinear2d_vec(const Tensor & input, c10::optional<IntArrayRef> output_size, bool align_corners, c10::optional<ArrayRef<double>> scale_factors);
  Tensor upsample_nearest2d_vec(const Tensor & input, c10::optional<IntArrayRef> output_size, c10::optional<ArrayRef<double>> scale_factors);
  Tensor upsample_nearest3d_vec(const Tensor & input, c10::optional<IntArrayRef> output_size, c10::optional<ArrayRef<double>> scale_factors);
  Tensor upsample_bilinear2d(const Tensor & self, IntArrayRef output_size, bool align_corners, c10::optional<double> scales_h, c10::optional<double> scales_w);
  Tensor upsample_nearest2d(const Tensor & self, IntArrayRef output_size, c10::optional<double> scales_h, c10::optional<double> scales_w);
  Tensor upsample_nearest3d(const Tensor & self, IntArrayRef output_size, c10::optional<double> scales_d, c10::optional<double> scales_h, c10::optional<double> scales_w);
}

} // namespace at
