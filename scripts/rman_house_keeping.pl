#!/usr/bin/perl

=for comment

 Script:	rman_house_keeping.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Realiza a limpeza de arquivos antigos (backup e walfiles) a partir da retenção configurada para
 cada servidor no arquivo .ini informado. Envia email, no caso de excecao.
 
=cut

use Util;
use Util::Exception;
use Mail::Text;
use Error qw(:try);
use strict;

#
# constants
#
use constant EMAIL_SECTION	=> "EMAIL";
use constant EMAIL_FIELDS	=> [ "smtp", "from", "list" ];
use constant EMAIL_SUBJECT	=> "RMAN House Keeping error";
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

use constant DEFAULT_CONF	=> "/etc/rman.ini";

#
# params
#
my $confPath	= shift;

if(($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

$confPath	= DEFAULT_CONF if(not defined $confPath);

# 
# vars
#
my $emailHash	= Util::readIniFileSection($confPath,EMAIL_SECTION,EMAIL_FIELDS);

#
# exec
#

# executa a limpeza para cada section
try
{
	foreach my $section (@{Util::getIniSections($confPath)})
	{
		next if($section eq EMAIL_SECTION);
		
		my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);
		
		# limpeza do diretório walfiles
		Util::removeOldFiles($$iniHash{wal_dir},$$iniHash{wal_keep}) if($$iniHash{wal_keep} > 0);
		
		# limpeza do diretório de backup
		if($$iniHash{backup_keep}>0)
		{
			my $limitDay	= Util::timestampFormattedString(time() - (86400 * $$iniHash{backup_keep}),"\%Y\%m\%d");
			
			foreach my $subdir (@{Util::listDirSubDirs($$iniHash{backup_dir},"[0-9]{8}")})
			{
				if($subdir < $limitDay)
				{
					Util::removeDir($$iniHash{backup_dir}."/".$subdir);
				}
			}
		}
	}
}
catch Util::Exception with
{
	my $ex	= shift;
	
	my $mailText	= Mail::Text->new();
	$mailText->setSubject(EMAIL_SUBJECT);
	$mailText->setData("Exception ".$ex->value().": ".$ex->text()."\n\n".$ex->stacktrace());
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
};

#
# functions
#

sub help
{
	my $message	= shift;
	
	print "
	Script $0 - Deleta arquivos antigos de backup e wal
	
	Params:
		- path do arquivo .ini (default /etc/rman.ini)\n\n";
	
	exit(0);
}