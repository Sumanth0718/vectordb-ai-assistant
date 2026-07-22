cmake_minimum_required(VERSION 3.12)
project(vectordb_ai_assistant CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find OpenSSL
find_package(OpenSSL REQUIRED)

add_executable(db main.cpp)

target_include_directories(db PRIVATE ${OPENSSL_INCLUDE_DIR})
target_link_libraries(db PRIVATE OpenSSL::SSL OpenSSL::Crypto)

# Enable OpenSSL support in httplib
target_compile_definitions(db PRIVATE CPPHTTPLIB_OPENSSL_SUPPORT)

# Thread library support for httplib
find_package(Threads REQUIRED)
target_link_libraries(db PRIVATE Threads::Threads)

if(APPLE)
    target_link_libraries(db PRIVATE "-framework CoreFoundation" "-framework Security")
endif()
