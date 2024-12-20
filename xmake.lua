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

    -- Clear the generated fl files.
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

    -- Install icons, docs and instruments
    after_install(function (target)
        import("privilege.sudo")
        if sudo.has() then
            -- Install documentation
            sudo.run("mkdir -p /usr/local/share/doc/non-sequencer")
            sudo.run("cp -r $(scriptdir)/doc/* /usr/local/share/doc/non-sequencer")

            -- Install icons at multiple sizes
            local sizes = {"16x16", "24x24", "32x32", "36x36", "48x48", "64x64", "72x72", "96x96", "128x128", "192x192", "256x256", "512x512", "scalable" }
            for _, size in ipairs(sizes) do
                local src = string.format("$(scriptdir)/icons/hicolor/%s/apps/non-sequencer.png", size)
                local dest_dir = string.format("/usr/local/share/icons/hicolor/%s/apps", size)
                sudo.run(string.format("mkdir -p %s", dest_dir))
                sudo.run(string.format("cp -f %s %s", src, dest_dir))
            end

            -- Install pixmap
            sudo.run("mkdir -p /usr/local/share/pixmaps")
            sudo.run("cp -f $(scriptdir)/icons/hicolor/256x256/apps/non-sequencer.png /usr/local/share/pixmaps/non-sequencer")

            -- Install instruments
            sudo.run("mkdir -p /usr/local/share/non-sequencer/instruments")
            sudo.run("cp -r $(scriptdir)/instruments/* /usr/local/share/non-sequencer/instruments")
        end
    end)

    -- Remove icons, docs and instruments
    after_uninstall(function (target)
        import("privilege.sudo")
        if sudo.has() then
            -- Remove documentation
            sudo.run("rm -rf /usr/local/share/doc/non-sequencer")

            -- Remove icons
            local sizes = { "16x16", "24x24", "32x32", "36x36", "48x48", "64x64", "72x72", "96x96", "128x128", "192x192", "256x256", "512x512", "scalable" }
            for _, size in ipairs(sizes) do
                sudo.run(string.format("rm -f /usr/local/share/icons/hicolor/%s/apps/non-sequencer.png", size))
            end

            -- Remove pixmaps
            sudo.run("rm -f /usr/local/share/pixmaps/non-sequencer")

            -- Remove instruments
            sudo.run("rm -rf /usr/local/share/non-sequencer/instruments")
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
   