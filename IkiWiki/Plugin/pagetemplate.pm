#!/usr/bin/perl
package IkiWiki::Plugin::pagetemplate;

use warnings;
use strict;
use IkiWiki 3.00;

my %templates;

sub import {
	hook(type => "getsetup", id => "pagetemplate", call => \&getsetup);
	hook(type => "checkconfig", id => "pagetemplate", call => \&checkconfig);
	hook(type => "preprocess", id => "pagetemplate", call => \&preprocess);
	hook(type => "templatefile", id => "pagetemplate", call => \&templatefile);
}

sub getsetup () {
	return 
		plugin => {
			safe => 1,
			rebuild => undef,
		},
		pagetemplate_matching => {
			type => "string",
			description => "list which page templates apply to which matching pages",
			example => {
				'discussion.tmpl' => '*/discussion',
				'blog.tmpl' => 'blog/*',
			},
			advanced => 1,
			safe => 1,
			rebuild => 1,
		},
}

sub checkconfig () {

	while (my ($tmpl, $spec) = each %{$config{pagetemplate_matching}})
	{
	    if (! defined $tmpl ||
		$tmpl !~ /^[-A-Za-z0-9._+]+$/ ||
		! defined IkiWiki::template_file($tmpl))
	    {
		error sprintf(gettext("pagetemplate_matching: bad or missing template '%s'"), $tmpl)
	    }
	    if (!IkiWiki::pagespec_valid($spec))
	    {
		error sprintf(gettext("pagetemplate_matching: invalid pagespec '%s' for template '%s'"), $spec, $tmpl)
	    }
	}
	return;
}

sub preprocess (@) {
	my %params=@_;

	if (! exists $params{template} ||
	    $params{template} !~ /^[-A-Za-z0-9._+]+$/ ||
	    ! defined IkiWiki::template_file($params{template})) {
		 error gettext("bad or missing template")
	}

	if ($params{page} eq $params{destpage}) {
		$templates{$params{page}}=$params{template};
	}

	return "";
}

sub templatefile (@) {
	my %params=@_;

	# Check for a template defined by a directive
	if (exists $templates{$params{page}}) {
		return $templates{$params{page}};
	}

	# Otherwise, check for a template pagespec
	while (my ($tmpl, $spec) = each %{$config{pagetemplate_matching}})
	{
	    if (pagespec_match($params{page}, $spec))
	    {
		return $tmpl;
	    }
	}
	
	return undef;
}

1
