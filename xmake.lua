-- TODO:
-- Need to automate .fl code generation

-- Does xmake disable sse2 by default?
option("NativeOptimizations")
    set_default(true)
    set_showmenu(true)
    add_vectorexts("sse2")

target("non-sequencer")
    add_options("NativeOptimizations")
    set_kind("binary")
    add_files("src/*.C")
    add_files("src/gui/*.C")
    add_files("src/NSM/*.C")

    -- nonlib files
    add_files("nonlib/*.C")
    add_files("nonlib/MIDI/*.C")
    add_files("nonlib/OSC/*.C")
    add_files("nonlib/JACK/*.C")
    -- NSM support is already in src
    -- add_files("nonlib/NSM/*.C")

    -- FL Files
    add_files("FL/*.C")
    --add_files("FL/util/*.C")

    -- Preprocessor definitions
    add_defines("VERSION=\"2\"")
    add_defines("SYSTEM_PATH=\"/usr/local/share/non-sequencer\"")
    add_defines("DOCUMENT_PATH=\"/usr/local/share/doc\"")
    add_defines("PIXMAP_PATH=\"/usr/local/share/pixmaps\"")

    -- Include directories
    add_includedirs("nonlib")
    add_includedirs("FL")
    add_sysincludedirs("/usr/local/include/ntk")
    add_sysincludedirs("/usr/include/sigc++-2.0")
    add_sysincludedirs("/usr/lib/x86_64-linux-gnu/sigc++-2.0/include")

    -- Link system libraries
    add_syslinks("pthread", "jack", "sigc-2.0", "lo", "X11", "ntk", "ntk_images", "cairo")

    before_build(function (target)
        os.cd("src/gui")
        os.run("ntk-fluid -c ui.fl")
        os.run("ntk-fluid -c event_edit.fl")
        os.cd("-")
        os.cd("FL")
        os.run("ntk-fluid -c About_Dialog.fl")
        os.run("ntk-fluid -c Fl_Text_Edit_Window.fl")
        os.run("ntk-fluid -c New_Project_Dialog.fl")
        os.cd("-")
    end)
   