/*******************************************************************************/
/* Copyright (C) 2012 Jonathan Moore Liles                                     */
/*                                                                             */
/* This program is free software; you can redistribute it and/or modify it     */
/* under the terms of the GNU General Public License as published by the       */
/* Free Software Foundation; either version 2 of the License, or (at your      */
/* option) any later version.                                                  */
/*                                                                             */
/* This program is distributed in the hope that it will be useful, but WITHOUT */
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       */
/* FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for   */
/* more details.                                                               */
/*                                                                             */
/* You should have received a copy of the GNU General Public License along     */
/* with This program; see the file COPYING.  If not,write to the Free Software */
/* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
/*******************************************************************************/

#include "NSM.H"

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "common.h"
#include "config.h"
#include "non.H"
#include "jack.H"
#include "transport.H"

#include "gui/ui.H"

#define OSC_INTERVAL 0.2f

extern Transport transport;
extern char *instance_name;

extern NSM_Client *nsm;
extern UI *ui;

extern int nsm_quit;
extern int got_sigterm;
extern int force_show_gui;

NSM_Client::NSM_Client ( )
{
    //project_filename = 0;
}

int command_open ( const char *name, const char *display_name, const char *client_id, char **out_msg );
int command_save ( char **out_msg );


int
NSM_Client::command_save ( char **out_msg )
{
    save_song( nsm->project_filename );
    return ERR_OK;
}

int 
NSM_Client::command_open ( const char *name, const char *display_name, const char *client_id, char **out_msg )
{
    // if ( instance_name )
    //     free ( instance_name );

    // instance_name = strdup ( client_id );
    // transport.osc_endpoint->name ( client_id );
    if ( transport.rolling )
    {
        *out_msg = strdup( "Cannot open while transport is running." );
        
        return ERR_NOT_NOW;
    }

    if ( song.dirty() )
    {
        *out_msg = strdup( "Song has unsaved changes!" );

        return ERR_UNSAVED_CHANGES;
    }

    if ( instance_name )
        free( instance_name );

    instance_name = strdup( client_id );

    if ( ! midi_is_active() )
    {
        setup_jack();
    }
    else
    {
        midi_all_sound_off();
        midi_shutdown();
        setup_jack();
    }

    char *new_filename;
    
    asprintf( &new_filename, "%s.non", name );

    struct stat st;

    if ( 0 == stat( new_filename, &st ) )
    {
        if ( ! load_song( new_filename ) )
        {
            *out_msg = strdup( "Could not open file" );
            return ERR_GENERAL;
        }
    }
    else
    {
        save_song( new_filename );
    }

    if ( nsm->project_filename )
        free( nsm->project_filename );
    
    nsm->project_filename = new_filename;

    return ERR_OK;
    
#ifdef HIDEGUI
    // IDK if this does anything
    if (force_show_gui) {
        nsm->nsm_send_is_shown ( nsm );
    } else {
        nsm->nsm_send_is_hidden ( nsm );
    }
#endif

}

void
NSM_Client::command_active ( bool b )
{
    if ( b )
    {
        ui->sm_indicator->value( 1 );
        ui->sm_indicator->tooltip( session_manager_name() );
    }
    else
    {
        ui->sm_indicator->tooltip( NULL );
        ui->sm_indicator->value( 0 );
    }
}

void
NSM_Client::command_hide_gui( void )
{
    ui->command_hide_gui ( );
}

void
NSM_Client::command_show_gui( void )
{
    ui->command_show_gui ( );
}

int
NSM_Client::command_quit(char **out_msg) {
    got_sigterm = 1;
    nsm_quit = 1;
    return ERR_OK;
}
