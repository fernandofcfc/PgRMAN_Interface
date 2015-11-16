#!/usr/bin/perl

=for comment

 Script:	rman_report.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Cria relatório de backups realizados no dia passado como parâmetro. O relatório é enviado
 por email.
	
=cut

use Util;
use Mail::Text;
use strict;

#
# constants
#
use constant EMAIL_SECTION	=> "EMAIL";
use constant EMAIL_FIELDS	=> [ "smtp", "from", "list" ];
use constant EMAIL_SUBJECT	=> "RMAN backup list";
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

use constant DEFAULT_RETRO	=> 1;
use constant DEFAULT_CONF	=> "/etc/rman.ini";

#
# params
#
my $retro		= shift;
my $confPath	= shift;

if(($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

$retro		= DEFAULT_RETRO	if(not defined $retro);
$confPath	= DEFAULT_CONF if(not defined $confPath);

# 
# vars
#
my $emailHash	= Util::readIniFileSection($confPath,EMAIL_SECTION,EMAIL_FIELDS);
my $output		= "";
my $timestamp	= Util::timestampFormattedString(time()-(86400*$retro),"\%Y-\%m-\%d");

#
# exec
#

# gera relatório
foreach my $section (@{Util::getIniSections($confPath)})
{
	next if($section eq EMAIL_SECTION);	
	
	my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);
	
	$output	.= "Backup $section:\n";
	$output	.= `$$iniHash{prefix}/bin/pg_rman -B $$iniHash{backup_dir} show $timestamp`;
	$output	.= "\n";	
}

my $mailText	= Mail::Text->new();
$mailText->setSubject(EMAIL_SUBJECT." - $timestamp");
$mailText->setData("$output");
$mailText->setFrom($$emailHash{from});
	
if($$emailHash{list} =~ /ARRAY/)
{
	foreach my $to (@{$$emailHash{list}})
	{
		$mailText->addTo($to);
	}
}
else
{
	$mailText->addTo($$emailHash{list});
}     								
	
$mailText->send($$emailHash{smtp});

#
# functions
#

sub help
{
	my $message	= shift;
	
	print "
	Script $0 - Cria resumo dos backups realizados em todos os servidores do arquivo de configuracao e envia por email
	
	Params:
		- dia retroativo (default 1)
		- path do arquivo .ini (default /etc/rman.ini)\n\n";
		
	exit(0);
}