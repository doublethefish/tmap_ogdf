  cd ./ogdf-conda/src
  mkdir build
  cd build
  cmake .. -DCMAKE_GENERATOR="Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX=C:/ogdf/ -DCMAKE_GENERATOR_PLATFORM=x64 -DCMAKE_BUILD_TYPE=Release
  cmake --build . --config Release --target install -- /m
  cd ..
  rmdir /Q /S build\