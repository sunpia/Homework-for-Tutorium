cmake_minimum_required (VERSION 3.8)



set(CMAKE_CUDA_HOST_COMPILER $ENV{CU_CCBIN} CACHE PATH "Cuda host compiler dir")



project(Darmstadt_Assignment04 LANGUAGES C CXX CUDA)



set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} "-gencode arch=compute_60,code=sm_60" )

SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ./
    CACHE PATH "Single directory for all executable.")


set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")


add_executable(problem1 problem1.cu)# ../randoms/randoms.c)

add_executable(problem2 problem2.cu)# ../randoms/randoms.c)






# For linking ...

# Specify target & libraries to link it with

#target_link_libraries( problem1 -lfoobar )

#target_link_libraries(problem1 m)

#target_link_libraries(problem2 m)
