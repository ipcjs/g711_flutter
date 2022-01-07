cmake_minimum_required(VERSION 3.4.1)
add_library(g711
        # Sets the library as a shared library.
        SHARED
        # Provides a relative path to your source file(s).
        ../ios/Classes/g711_table.c
        ../ios/Classes/g711.c
        ../ios/Classes/native_add.cpp
        )
