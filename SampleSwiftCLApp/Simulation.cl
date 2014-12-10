__kernel void simulationStep(__global float *A, __global float *B, __global float *Result) {
  int idx = get_global_id(0);
  
  Result[idx] = A[idx] + B[idx];
}