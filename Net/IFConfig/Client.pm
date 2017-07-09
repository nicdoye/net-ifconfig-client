use strict;
use warnings;
use 5.10.0;
use feature qw/say switch/;
use REST::Client;
use JSON;

package Net::IFConfig::Client;
use Moose;

has 'server' => (
	is => 'ro',
	isa => 'Str',
	default => 'https://ifconfig.co/json',
	reader => 'get_server',
	writer => 'set_server'
);

has '_json' => (
	is => 'ro',
	isa => 'HashRef',
	default => sub{{}},
	reader => '_get_json',
	writer => '_set_json'
);

has '_raw_status' => (
	is => 'ro',
	isa => 'Int',
	default => 0,
	reader => 'get_raw_status',
	writer => '_set_raw_status'
);


sub get_status {
	my $self = shift;
	my $answer;
	given( $self->get_raw_status ) {
		$answer = undef when 0;
		$answer = 1 when 200;
		default { $answer = 0}
	}
	return $answer;
}


sub _request {
	my $self = shift;
	my $client = REST::Client->new();
	my $json = JSON->new();

  $client->GET($self->get_server());

	$self->_set_raw_status($client->responseCode());
	$self->get_status() and $self->_set_json($json->decode($client->responseContent()));
}


sub _request_if_not_ok {
	my $self = shift;
	$self->get_status() or $self->_request();
}

sub _elements {
	my ( $self, $element ) = @_;
	$self->_request_if_not_ok();
	return $self->_get_json->{$element};
}

sub city { return $_[0]->_elements('city'); }
sub country { return $_[0]->_elements('country'); }
sub hostname { return $_[0]->_elements('hostname'); }
sub ip { return $_[0]->_elements('ip'); }
sub ip_decimal { return $_[0]->_elements('ip_decimal'); }

1;