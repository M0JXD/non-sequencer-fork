target("non-sequencer")
    set_kind("binary")
    add_files("src/*.C", "src/gui/*.C")
    add_files("nonlib/*.C", "nonlib/MIDI/*.C", "nonlib/OSC/*.C", "nonlib/JACK/*.C", "nonlib/NSM/*.C")
    add_files("FL/*.C")
    --add_files("FL/util/*.C")

    add_rules("ntk-fluid")
    add_options("NativeOptimizations")

    add_defines("VERSION=\"2\"")
    add_defines("SYSTEM_PATH=\"/usr/local/share/non-sequencer\"")
    add_defines("DOCUMENT_PATH=\"/usr/local/share/doc\"")
    add_defines("PIXMAP_PATH=\"/usr/local/share/pixmaps\"")

    add_includedirs("nonlib", "FL")

    -- without this it trys to build against FLTK, despite sys_link below.
    add_sysincludedirs("/usr/local/include/ntk")
    -- sigc++ is odd, I really struggled forcing the build system (and intellisense) to find it.
    -- I think the original author wanted to remove this dependency anyways
    add_sysincludedirs("/usr/include/sigc++-2.0")
    add_sysincludedirs("/usr/lib/x86_64-linux-gnu/sigc++-2.0/include")

    add_syslinks("pthread", "jack", "sigc-2.0", "lo", "X11", "ntk", "ntk_images", "cairo")

    -- Clear the generated fl files.
    after_clean(function (target)
        os.rm("$(projectdir)/src/gui/**.C")
        os.rm("$(projectdir)/src/gui/**.H")
        os.rm("$(projectdir)/FL/About_Dialog.C")
        os.rm("$(projectdir)/FL/About_Dialog.H")
        os.rm("$(projectdir)/FL/Fl_Text_Edit_Window.C")
        os.rm("$(projectdir)/FL/Fl_Text_Edit_Window.H")
        os.rm("$(projectdir)/FL/New_Project_Dialog.C")
        os.rm("$(projectdir)/FL/New_Project_Dialog.H")
    end)

    -- Install icons, docs and instruments
    after_install(function (target) 
        import("privilege.sudo")
        if sudo.has() then
            -- Install documentation
            sudo.run("mkdir -p /usr/local/share/doc/non-sequencer")
            sudo.run("cp -r $(projectdir)/doc/. /usr/local/share/doc/non-sequencer")

            -- Install icons
            local sizes = {"16x16", "32x32", "36x36", "48x48", "64x64", "72x72", "96x96", "128x128", "192x192", "256x256", "512x512" }
            for _, size in ipairs(sizes) do
                local src = string.format("$(projectdir)/icons/hicolor/%s/apps/non-sequencer.png", size)
                local dest_dir = string.format("/usr/local/share/icons/hicolor/%s/apps", size)
                sudo.run(string.format("mkdir -p %s", dest_dir))
                sudo.run(string.format("cp -f %s %s", src, dest_dir))
            end

            -- Install pixmap
            sudo.run("mkdir -p /usr/local/share/pixmaps/non-sequencer")
            sudo.run("cp -f $(projectdir)/icons/hicolor/256x256/apps/non-sequencer.png /usr/local/share/pixmaps/non-sequencer/icon-256x256.png")

            -- Install instruments
            sudo.run("mkdir -p /usr/local/share/non-sequencer/instruments")
            sudo.run("cp -r $(projectdir)/instruments/. /usr/local/share/non-sequencer/instruments")

            -- Install desktop file
            sudo.run("cp $(projectdir)/non-sequencer.desktop.in /usr/local/share/applications/non-sequencer.desktop")
        end
    end)

    -- Remove icons, docs and instruments
    after_uninstall(function (target)
        import("privilege.sudo")
        if sudo.has() then
            -- Remove documentation
            sudo.run("rm -rf /usr/local/share/doc/non-sequencer")

            -- Remove icons
            local sizes = { "16x16", "32x32", "36x36", "48x48", "64x64", "72x72", "96x96", "128x128", "192x192", "256x256", "512x512" }
            for _, size in ipairs(sizes) do
                sudo.run(string.format("rm -f /usr/local/share/icons/hicolor/%s/apps/non-sequencer.png", size))
            end

            -- Remove pixmaps
            sudo.run("rm -rf /usr/local/share/pixmaps/non-sequencer")

            -- Remove instruments
            sudo.run("rm -rf /usr/local/share/non-sequencer/instruments")

            -- Remove dekstop
            sudo.run("rm -rf /usr/local/share/applications/non-sequencer.desktop")
        end
    end)

-- .fl code generation rule
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

-- SSE2 Optimisation Switch. TODO: Does xmake disable sse2 by default?
option("NativeOptimizations")
    set_default(true)
    set_showmenu(true)
    add_vectorexts("sse2")
   