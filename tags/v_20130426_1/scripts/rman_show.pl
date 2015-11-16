#!/usr/bin/perl

=for comment

 Script:	rman_show.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Print na tela do terminal os backups disponíveis para o servidor passado como parâmetro, contido
 no arquivo .ini informado.

=cut

use Util;
use strict;

#
# constants
#
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

use constant DEFAULT_CONF	=> "/etc/rman.ini";

#
# params
#
my $section		= shift;
my $timeStamp	= shift;
my $confPath	= shift;

if(($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

$timeStamp	= "" if(not defined $timeStamp);
$confPath	= DEFAULT_CONF if(not defined $confPath);

# 
# vars
#
my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);

#
# exec
#

# show
print `$$iniHash{prefix}/bin/pg_rman -B $$iniHash{backup_dir} show $timeStamp`;

#
# functions
#

sub help
{
	my $message	= shift;
	
	print "
	Script $0 - print dos backups disponiveis no repositorio para o servidor informado
	
	Params:
		- section existente no arquivo .ini
		- timestamp definida entre \"'s ou timeline (opcional)
		- path do arquivo .ini (default /etc/rman.ini)\n\n";
	
	exit(0);
}