package PDF::WebKit::Configuration;
use strict;
use warnings;
use Moo;
use namespace::clean;

has meta_tag_prefix => ( is => 'rw' );
has default_options => ( is => 'rw' );
has wkhtmltopdf     => ( is => 'rw', builder => '_find_wkhtmltopdf', lazy => 1 );

around 'BUILDARGS' => sub {
  my $orig = shift;
  my $self = shift;
  my $page_size = $ENV{LC_PAPER} || "";
  if ($page_size =~ m/^297\b/) {
    $page_size = "A4";
  }
  if (!$page_size && open my $fh, "<", "/etc/papersize") {
    chomp ($page_size = uc <$fh>);
    close $fh;
  }
  return $self->$orig({
    meta_tag_prefix => 'pdf-webkit-',
    default_options => {
      disable_smart_shrinking => undef,
      page_size => $page_size || 'Letter',
      margin_top => '0.75in',
      margin_right => '0.75in',
      margin_bottom => '0.75in',
      margin_left => '0.75in',
      encoding => "UTF-8",
    },
  });
};

sub _find_wkhtmltopdf {
  my $self = shift;
  my $which = $^O eq "MSWin32" ? "where" : "which";
  my $found = `$which wkhtmltopdf`;
  $?  and return;

  chomp($found);
  return $found;
}

my $_config;
sub configuration {
  $_config ||= PDF::WebKit::Configuration->new;
}

sub configure {
  my $class = shift;
  my $code = shift;
  local $_ = $class->configuration;
  $code->($_);
}

1;
