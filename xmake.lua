target("non-sequencer")
    set_kind("binary")
    add_files("src/*.C")
    -- add_deps("nonlib", "FL")
    
    add_defines("VERSION=2")
    -- N.B. need to not force a system path but pick it up from the build system
    add_defines("SYSTEM_PATH=\"/usr/local/share/non-sequencer\"")
    add_defines("DOCUMENT_PATH=\"/usr/local/share/doc\"")
    add_defines("PIXMAP_PATH=\"/usr/local/share/pixmaps\"")

    add_includedirs("nonlib")
    add_includedirs("FL")
    add_sysincludedirs("/usr/local/include/ntk")
    add_sysincludedirs("/usr/include/sigc++-2.0")
    add_sysincludedirs("/usr/lib/x86_64-linux-gnu/sigc++-2.0/include")
