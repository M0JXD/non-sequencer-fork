/**********************************************************************************/
/* Copyright (C) 2007,2008 Jonathan Moore Liles                                   */
/*                                                                                */
/* This program is free software; you can redistribute it and/or modify it        */
/*  under the terms of the GNU General Public License as published by the         */
/*  Free Software Foundation; either version 2 of the License, or (at your        */
/*  option) any later version.                                                    */
/*                                                                                */
/*  This program is distributed in the hope that it will be useful, but WITHOUT   */
/*  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or ;       */
/*  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for     */
/*  more details.                                                                 */
/*                                                                                */
/*  You should have received a copy of the GNU General Public License along       */
/*  with This program; see the file COPYING.  If not,write to the Free Software ; */
/*  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.    */
/**********************************************************************************/

#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string>

#include "non.H"
// #include "gui/input.H"
#include "gui/ui.H"
#include "jack.H"
#include "NSM.H"
#include "transport.H"
#include "pattern.H"
#include "phrase.H"
#include <signal.h>
#include <MIDI/midievent.H>
using namespace MIDI;

// extern const char *BUILD_ID;
// extern const char *VERSION;

/* needed for extern to be compatible with non-xt*/
std::string project_directory = "";

const double NSM_CHECK_INTERVAL = 0.25f;

sequence *playlist;

global_settings config;
song_settings song;

NSM_Client *nsm;

char *instance_name;

int nsm_quit = 0;
int got_sigterm = 0;

/* default to pattern mode */
UI *ui;

#ifdef HIDEGUI
// TODO: For save_window_sizes, should go in ui.fl
int _x_parent, _y_parent, _w_parent, _h_parent;
#endif

void
quit ( void )
{
#ifdef HIDEGUI
    // If we're NSM just hide the GUI
    if ( nsm->is_active ( ) && !nsm_quit )
    {
        nsm->nsm_send_is_hidden ( nsm );
        while ( Fl::first_window ( ) ) Fl::first_window ( )->hide ( );
        got_sigterm = 0;
    }
    else // Terminate the program
#endif
    {
        /* clean up, only for valgrind's sake */
        ui->save_settings();
#ifdef HIDEGUI
        if (song.filename != NULL || nsm->is_active()) {
            save_window_sizes();
        }
#endif

        delete ui;
        midi_all_sound_off();

        // wait for it...
        sleep( 1 );

        midi_shutdown();

        MESSAGE( "Your fun is over" );

        exit( 0 );
    }
}

void
clear_song ( void )
{
//    song.filename = NULL;

    ui->pattern_canvas_widget->grid( NULL );
    ui->phrase_canvas_widget->grid( NULL );

    playlist->reset();
    playlist->insert( 0, 1 );

    ui->pattern_canvas_widget->grid( new pattern );
    ui->phrase_canvas_widget->grid( new phrase );

    song.dirty( false );
}

void
init_song ( void )
{
    if ( ! midi_is_active() )
        setup_jack();

    if ( !( nsm && nsm->is_active() ) )
        song.filename = NULL;

    clear_song();

    if ( nsm && nsm->is_active() )
        save_song( song.filename );
}

void
handle_midi_input ( void )
{
    midievent e;
    while ( ( midi_input_event( PERFORMANCE, &e ) ) )
    {
        pattern::record_event( &e );
    }
}

bool
load_song ( const char *name )
{
    if ( ! midi_is_active() )
        setup_jack();

    MESSAGE( "loading song \"%s\"", name );

    Grid *pattern_grid = ui->pattern_canvas_widget->grid();
    Grid *phrase_grid = ui->phrase_canvas_widget->grid();

    ui->pattern_canvas_widget->grid( NULL );
    ui->phrase_canvas_widget->grid( NULL );

    if ( ! playlist->load( name ) )
    {
        WARNING( "failed to load song file" );
        goto failed;
    }

    ui->pattern_canvas_widget->grid( pattern::pattern_by_number( 1 ) );
    ui->phrase_canvas_widget->grid( phrase::phrase_by_number( 1 ) );

    song.filename = strdup( name );

    song.dirty( false );

    return true;

failed:

    ui->pattern_canvas_widget->grid( pattern_grid );
    ui->phrase_canvas_widget->grid( phrase_grid );

    return false;
}

bool
save_song ( const char *name )
{
    playlist->save( name );

    song.filename = strdup( name );
    song.dirty( false );
#ifdef HIDEGUI
    save_window_sizes();
#endif
    return true;
}

void
setup_jack ( )
{
   const char *jack_name;

    jack_name = midi_init( instance_name );
    if ( ! jack_name )
        ASSERTION( "Could not initialize MIDI system! (is Jack running and with MIDI ports enabled?)" );

    if ( ! transport.valid )
    {
        if ( transport.master )
            ASSERTION( "The version of JACK you are using does not appear to be capable of passing BBT positional information." );
        else
            ASSERTION( "Either the version of JACK you are using does pass BBT information, or the current timebase master does not provide it." );
    }
}

#ifdef HIDEGUI
// TODO: These functions really should be encapsulated in ui.fl, but because fluid keeps breaking them they're here for now
void
save_window_sizes ( void ) 
{
    char* path;
    asprintf( &path, "%s/%s", config.user_config_dir, "window" );

    if( ( _x_parent == ui->main_window->x() ) && ( _y_parent ==  ui->main_window->y() ) &&
        ( _w_parent ==  ui->main_window->w() ) && (_h_parent == ui->main_window->h() ) )
    {
        return; // nothing changed
    }

    FILE *fp = fopen ( path, "w" );

    if ( !fp )
    {
        printf ( "Error opening window file for writing\n" );
        return;
    }

    fprintf ( fp, "%d:%d:%d:%d\n", ui->main_window->x(), ui->main_window->y(), ui->main_window->w(), ui->main_window->h());

    fclose ( fp );
    free( path );
}

void
load_window_sizes ( void ) 
{
    char* path;
    asprintf( &path, "%s/%s", config.user_config_dir, "window" );

    FILE *fp = fopen ( path, "r" );

    if ( !fp )
    {
        printf ( "Error opening window file for reading\n" );
        return;
    }

    while ( 4 == fscanf ( fp, "%d:%d:%d:%d\n]\n", &_x_parent, &_y_parent, &_w_parent, &_h_parent ) )
    {
    }

    ui->main_window->resize ( _x_parent, _y_parent, _w_parent, _h_parent );

    fclose ( fp );
    free( path );
}
#endif

void
sigterm_handler ( int )
{
    got_sigterm = 1;
    // For some reason raysession quits this way?
    // Regardless any external sigterm should be treated seriously.
    nsm_quit = 1;
    Fl::awake();
}

void
check_sigterm ( void * )
{
    if ( got_sigterm )
    {
        MESSAGE( "Got SIGTERM, quitting..." );
        nsm_quit = 1;
        quit();
    }
}

void
check_nsm ( void * v )
{
    nsm->check();
    Fl::repeat_timeout( NSM_CHECK_INTERVAL, check_nsm, v );
}

int
main ( int argc, char **argv )
{
    printf( "%s %s %s -- %s\n", APP_TITLE, VERSION, "", COPYRIGHT );

    if ( ! Fl::visual( FL_DOUBLE | FL_RGB ) )
    {
        WARNING( "Xdbe not supported, FLTK will fake double buffering." );
    }

    got_sigterm = 0;
    nsm_quit = 0;
    ::signal( SIGTERM, sigterm_handler );
    ::signal( SIGHUP, sigterm_handler );
    ::signal( SIGINT, sigterm_handler );

    config.follow_playhead = true;
    config.record_mode = MERGE;
    song.play_mode = PATTERN;

    asprintf( &config.user_config_dir, "%s/%s", getenv( "HOME" ), USER_CONFIG_DIR );
    mkdir( config.user_config_dir, 0777 );

    playlist = new sequence;

    nsm = new NSM_Client;

    song.filename = NULL;

    ui = new UI;

    pattern::signal_create_destroy.connect( mem_fun( ui->phrase_canvas_widget,  &Canvas::v_zoom_fit ) );
    pattern::signal_create_destroy.connect( mem_fun( song, &song_settings::set_dirty ) );
    phrase::signal_create_destroy.connect( mem_fun( song, &song_settings::set_dirty ) );

    song.dirty( false );

    clear_song();

    // // "The main thread must call lock() to initialize the threading support in FLTK."
    // Fl::lock ( );

    const char *nsm_url = getenv( "NSM_URL" );

#ifdef HAVE_XPM
    ui->main_window->icon((char *)p);
#endif

#ifdef HIDEGUI
    load_window_sizes();
#endif

    if ( !nsm_url )
    {
        ui->main_window->show( 0, 0 );
    }

#ifndef HIDEGUI
    ui->main_window->show( 0, 0 );
#endif
    
    instance_name = strdup( APP_NAME );

    if ( nsm_url )
    {
        if ( ! nsm->init( nsm_url ) )
        {
#ifdef HIDEGUI
            nsm->announce( APP_NAME, ":switch:dirty:optional-gui:", argv[0] );
#else
            nsm->announce( APP_NAME, ":switch:dirty:", argv[0] );
#endif
            
            song.signal_dirty.connect( sigc::mem_fun( nsm, &NSM_Client::is_dirty ) );
            song.signal_clean.connect( sigc::mem_fun( nsm, &NSM_Client::is_clean ) );

            // poll so we can keep OSC handlers running in the GUI thread and avoid extra sync
            Fl::add_timeout( NSM_CHECK_INTERVAL, check_nsm, NULL );
        }       
        else
            WARNING( "Error initializing NSM" );
    }
    else
    {
        setup_jack();
        if ( argc > 1 )
        {
            /* maybe a filename on the commandline */
            if ( ! load_song( argv[ 1 ] ) )
                ASSERTION( "Could not load song \"%s\" specified on command line", argv[ 1 ] );
        }
    }

    MESSAGE( "Initializing GUI" );

    Fl::add_check( check_sigterm );

    ui->load_settings();

#ifdef HIDEGUI
    if ( !nsm_url )
#endif
    {
        DMESSAGE ( "Running UI..." );
        ui->run ( );
    }
#ifdef HIDEGUI
    else

    {
        while ( !got_sigterm )
        {
            Fl::wait ( 2147483.648 ); /* magic number means forever */
        }
        quit();
    }
#endif
    return 0;
}
