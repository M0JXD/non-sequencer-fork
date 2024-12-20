target("non-sequencer")
    set_kind("binary")
    add_files("src/*.C", "src/gui/*.C", "src/NSM/*.C")
    add_files("nonlib/*.C", "nonlib/MIDI/*.C", "nonlib/OSC/*.C", "nonlib/JACK/*.C")
    -- add_files("nonlib/NSM/*.C")  -- NSM support is already in src
    add_files("FL/*.C")
    --add_files("FL/util/*.C")

    add_rules("ntk-fluid")
    add_options("NativeOptimizations")

    add_defines("VERSION=\"2\"")
    add_defines("SYSTEM_PATH=\"/usr/local/share/non-sequencer\"")
    add_defines("DOCUMENT_PATH=\"/usr/local/share/doc\"")
    add_defines("PIXMAP_PATH=\"/usr/local/share/pixmaps\"")

    add_includedirs("nonlib", "FL")
    add_sysincludedirs("/usr/local/include/ntk")
    add_sysincludedirs("/usr/include/sigc++-2.0")
    add_sysincludedirs("/usr/lib/x86_64-linux-gnu/sigc++-2.0/include")
    add_syslinks("pthread", "jack", "sigc-2.0", "lo", "X11", "ntk", "ntk_images", "cairo")

    after_clean(function (target)
        os.rm("$(scriptdir)/src/gui/**.C")
        os.rm("$(scriptdir)/src/gui/**.H")
        os.rm("$(scriptdir)/FL/About_Dialog.C")
        os.rm("$(scriptdir)/FL/About_Dialog.H")
        os.rm("$(scriptdir)/FL/Fl_Text_Edit_Window.C")
        os.rm("$(scriptdir)/FL/Fl_Text_Edit_Window.H")
        os.rm("$(scriptdir)/FL/New_Project_Dialog.C")
        os.rm("$(scriptdir)/FL/New_Project_Dialog.H")
    end)

    after_install(function (target)
        -- TODO: Copy the icons, docs and instruments 
        
    end)

rule("ntk-fluid")
    -- Build the .fl files
    on_load(function (target)
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

option("NativeOptimizations")
    -- Does xmake disable sse2 by default?
    set_default(true)
    set_showmenu(true)
    add_vectorexts("sse2")
   