cmake_minimum_required(VERSION 3.10)
project(SHA256_Project C)
set(CMAKE_C_STANDARD 11)

find_package(OpenSSL REQUIRED)

add_compile_options(-Wno-deprecated-declarations)

add_executable(server src/server.c)
target_link_libraries(server OpenSSL::Crypto)

add_executable(client src/client.c)
target_link_libraries(client OpenSSL::Crypto)

add_executable(admin  src/admin.c)
