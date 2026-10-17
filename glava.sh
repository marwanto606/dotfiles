#!/usr/bin/env bash
set -e

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

install_glava() {
    echo "==========================================="
    echo "  1. Menginstall Dependensi & Build Tools  "
    echo "==========================================="
    sudo apt update
    sudo apt install -y \
        meson \
        ninja-build \
        build-essential \
        gcc \
        g++ \
        git \
        libgl1-mesa-dev \
        libpulse0 \
        libpulse-dev \
        libx11-dev \
        libxext-dev \
        libxrender-dev \
        libxcomposite-dev \
        liblua5.3-dev \
        liblua5.3-0 \
        lua-lgi \
        lua-filesystem

    echo "==========================================="
    echo "  2. Mengunduh & Patch Kode Glava          "
    echo "==========================================="
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/jarcode-foss/glava.git "$TEMP_DIR/glava"
    cd "$TEMP_DIR/glava"

    echo "-> Menerapkan patch kompatibilitas GCC 14..."
    # Patch header yang hilang (cstdio, cerrno, stdexcept, cstdint)
    sed -i '1i #include <cstdio>\n#include <cerrno>' glfft/glfft_gl_interface.hpp
    sed -i '1i #include <stdexcept>' glfft/glfft_wisdom.cpp
    sed -i '1i #include <cstdint>' glfft/glfft_common.hpp
    sed -i '1i #include <cstdint>' glfft/glfft_wisdom.hpp
    sed -i '1i #include <cstdint>' glfft/glfft.cpp

    echo "-> Memperbaiki sintaks Meson & Warning C++..."
    # Memperbaiki sintaks meson yang lama
    sed -i "s/meson.source_root()/meson.project_source_root()/g" meson.build
    sed -i "s/run_command(git, 'rev-parse'/run_command(git, 'rev-parse', check: false/g" meson.build
    
    # Menghilangkan warning: command-line option '-std=c++11' is valid for C++ but not for C
    # Kita hapus baris yang memaksakan std=c++11 pada bahasa C di meson.build
    sed -i "s/add_project_arguments('-std=c++11', language: 'c')//g" meson.build

    echo "==========================================="
    echo "  3. Mengompilasi Glava                   "
    echo "==========================================="
    # -fcommon: Mengatasi multiple definition error
    # -Ddisable_obs=true: Agar build lebih ringan & portable (tidak butuh libobs-dev)
    meson setup build --prefix /usr \
        -Ddisable_obs=true \
        -Dc_args='-fcommon -Wno-unused-but-set-variable'

    ninja -C build

    echo "==========================================="
    echo "  4. Memasang Glava ke Sistem             "
    echo "==========================================="
    sudo ninja -C build install
    sudo ldconfig

    echo "==========================================="
    echo "  5. Inisialisasi Konfigurasi User         "
    echo "==========================================="
    if [ ! -f "$HOME/.config/glava/rc.glsl" ]; then
        glava --copy-config || true
    fi

    echo ""
    echo "✔ Sukses! Glava berhasil diinstall tanpa error di GCC 14."
}

uninstall_glava() {
    echo "==========================================="
    echo "  Menghapus Glava dari Sistem             "
    echo "==========================================="
    sudo rm -f /usr/bin/glava
    sudo rm -f /usr/lib/x86_64-linux-gnu/libglava.so
    sudo rm -f /usr/lib/libglava.so
    sudo rm -rf /etc/xdg/glava
    sudo ldconfig
    echo "✔ Glava berhasil di-uninstall."
}

show_usage() {
    echo "Penggunaan: $0 {install|uninstall|reinstall}"
    exit 1
}

case "$1" in
    install) install_glava ;;
    uninstall) uninstall_glava ;;
    reinstall) uninstall_glava; install_glava ;;
    *) show_usage ;;
esac