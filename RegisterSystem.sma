#include <amxmodx>
#include <amxmisc>
#include <ColorChat>
#include <fvault>

new const Vault[ ] = "RegisterSystemSave";

#define Prefix "^4[ ^3EmpireState ^4]^1"
#define MenuPrefix "\r[\wEmpireState\r]\w"

enum _:PlayerData
{
	Status,
	MenuPassword[ 60 ],
	Password[ 60 ]
}

new pInfo[ 33 ][ PlayerData ];

public plugin_init() {
	register_plugin("Register System", "1.0", "[eTy]Magician");

	register_clcmd("say", "CmdSay");
	register_clcmd("say_team", "CmdSay");
	register_clcmd("chooseteam", "BlockMainMenu");
	
	register_clcmd(" _password_", "CmdPassword");
}

public CmdSay( id )
{
	new szMsg[ 192 ], szArgs[ 3 ][ 32 ];
	
	read_argv( 1, szMsg, charsmax( szMsg ) );
	
	parse( szMsg, szArgs[ 0 ], 31, szArgs[ 1 ], 31, szArgs[ 2 ], 31 );
	
	if( equali( szArgs[ 0 ], "/login" ) )
		return LoginMenu( id );
		
	if( equali( szArgs[ 0 ], "/register" ) )
		return RegisterMenu( id );
		
	if( pInfo[ id ][ Status ] != 2 )
	{
		ColorChat(id, NORMAL, "%s You need to^3 %s^1 before you can^4 write in chat^1. Type^3 /%s^1 in chat.", Prefix, pInfo[ id ][ Status ] == 0 ? "register" : "login", pInfo[ id ][ Status ] == 0 ? "register" : "login");
		return 1;
	}
	return 0;
}

public BlockMainMenu( id )
{
	if( pInfo[ id ][ Status ] != 2 )
	{
		ColorChat(id, BLUE, "%s You need to^3 %s^1 before you can^4 open this menu^1. Type^3 /%s^1 in chat.", Prefix, pInfo[ id ][ Status ] == 0 ? "register" : "login", pInfo[ id ][ Status ] == 0 ? "register" : "login");
		return 1;
	}
	return PLUGIN_CONTINUE;
}

public RegisterMenu( id )
{
	if( pInfo[ id ][ Status ] > 0 )
	{
		ColorChat(id, NORMAL, "%s Your^3 account^1 is^4 already exist^1.", Prefix);
		return 1;
	}
	
	new szMenu[ 128 ];
	formatex( szMenu, charsmax( szMenu ), "%s Register Menu", MenuPrefix );
	
	new menu = menu_create( szMenu, "RegisterMenu_handler" );
	
	formatex( szMenu, charsmax( szMenu ), "\wPassword:\r %s^n", pInfo[ id ][ MenuPassword ] );
	menu_additem( menu, szMenu, "0" );
	
	formatex( szMenu, charsmax( szMenu ), "\wRegister" );
	menu_additem( menu, szMenu, "1", equali( pInfo[ id ][ MenuPassword ], "" ) ? (1<<31) : ADMIN_ALL );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER );
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;	
}

public RegisterMenu_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		RegisterMenu( id );
		return 1;
	}

	if( pInfo[ id ][ Status ] > 0 )
	{
		ColorChat(id, NORMAL, "%s Your^3 account^1 is^4 already exist^1.", Prefix);
		return 1;
	}
	
	switch( item )
	{
		case 0:
		{
			client_cmd(id, "messagemode _password_");
			RegisterMenu( id );
		}
		
		case 1:
		{
			pInfo[ id ][ Status ] = 1;
			formatex( pInfo[ id ][ Password ], 59, "%s", pInfo[ id ][ MenuPassword ] );
			pInfo[ id ][ MenuPassword ] = "";
			LoginMenu( id );
			ColorChat(0, NORMAL, "%s The player^3 %s^1 has^4 registerred^1 to the server.", Prefix, GetName( id ));
			CmdSave( id );
		}
	}
	return 1;
}

public LoginMenu( id )
{
	if( pInfo[ id ][ Status ] == 0 )
	{
		ColorChat(id, NORMAL, "%s You need to^3 register^1 before you can^3 login^1.", Prefix);
		return 1;
	}
	else if( pInfo[ id ][ Status ] == 2 )
	{
		ColorChat(id, NORMAL, "%s You already^4 logged in^1 to the server.", Prefix);
		return 1;
	}
	
	new szMenu[ 128 ];
	formatex( szMenu, charsmax( szMenu ), "%s Login Menu", MenuPrefix );
	
	new menu = menu_create( szMenu, "LoginMenu_handler" );
	
	formatex( szMenu, charsmax( szMenu ), "\wPassword:\r %s^n", pInfo[ id ][ MenuPassword ] );
	menu_additem( menu, szMenu, "0" );
	
	formatex( szMenu, charsmax( szMenu ), "\wLogin" );
	menu_additem( menu, szMenu, "1", equali( pInfo[ id ][ MenuPassword ], "" ) ? (1<<31) : ADMIN_ALL );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER );
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;	
}

public LoginMenu_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		LoginMenu( id );
		return 1;
	}

	if( pInfo[ id ][ Status ] == 0 )
	{
		ColorChat(id, NORMAL, "%s You need to^3 register^1 before you can^3 login^1.", Prefix);
		return 1;
	}
	else if( pInfo[ id ][ Status ] == 2 )
	{
		ColorChat(id, NORMAL, "%s You already^4 logged in^1 to the server.", Prefix);
		return 1;
	}
	
	switch( item )
	{
		case 0:
		{
			client_cmd(id, "messagemode _password_");
			LoginMenu( id );
		}
		
		case 1:
		{
			if(!( equali( pInfo[ id ][ MenuPassword ], pInfo[ id ][ Password ] ) ))
			{
				ColorChat(id, NORMAL, "%s The^4 password^1 is wrong.", Prefix);
				pInfo[ id ][ MenuPassword ] = "";
				LoginMenu( id );
				return 1;
			}
			ColorChat(id, NORMAL, "%s You^3 logged in^1 to the^4 server^1.", Prefix);
			pInfo[ id ][ MenuPassword ] = "";
			pInfo[ id ][ Status ] = 2;
		}
	}
	return 1;
}

public CmdPassword( id )
{
	if( pInfo[ id ][ Status ] == 2 )
		return PLUGIN_HANDLED;
		
	new szArgs[ 60 ];
	read_args( szArgs, charsmax( szArgs ) );
	remove_quotes( szArgs );
	
	if( strlen( szArgs ) < 3 || strlen( szArgs ) > 10 )
		return PLUGIN_HANDLED;
	
	formatex( pInfo[ id ][ MenuPassword ], 59, "%s", szArgs);
	
	if( pInfo[ id ][ Status ] == 0 ) RegisterMenu( id );
	else if( pInfo[ id ][ Status ] == 1 ) LoginMenu( id );
	return 1;
}

public client_putinserver( id )
{
	pInfo[ id ][ MenuPassword ] = "";
	CmdLoad( id );
}

public client_disconnect( id )
{
	if( pInfo[ id ][ Status ] == 2 )
	{
		pInfo[ id ][ Status ] = 1;
		CmdSave( id );
	}
}

public CmdSave( id )
{
	new Key[ 64 ], Data[ 256 ];
	formatex( Key, charsmax( Key ), "%s-sSystem", szAuth( id ) );
	formatex( Data, charsmax( Data ), "%i#%s#", pInfo[ id ][ Status ], pInfo[ id ][ Password ]);
	fvault_set_data( Vault, Key, Data );
}

public CmdLoad( id )
{
	new Key[ 64 ], Data[ 256 ];
	formatex( Key, charsmax( Key ), "%s-sSystem", szAuth( id ) );
	formatex( Data, charsmax( Data ), "%i#%s#", pInfo[ id ][ Status ], pInfo[ id ][ Password ]);
	
	fvault_get_data( Vault, Key, Data, 255 );
	replace_all( Data, 255, "#", " " );
	
	new SetData[ 2 ][ 32 ];
	parse( Data, SetData[ 0 ], 31, SetData[ 1 ], 31 );
	
	pInfo[ id ][ Status ]		= str_to_num( SetData[ 0 ] );
	pInfo[ id ][ Password ]		= SetData[ 1 ];
}

stock szAuth( const index )
{
	static Auth[ 35 ];
	get_user_authid( index, Auth, charsmax( Auth ) );
	return Auth;
}

stock GetName( id )
{
	static Name[ 32 ];
	get_user_name( id, Name, charsmax( Name ) );
	return Name;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
