package AI::Proplog;

require 5.005_62;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our $debug = 0;

our $VERSION = '0.01';



# Preloaded methods go here.

sub new {
    my $pkg = shift;

    my %self;


    my $self = bless { clause => [] }, $pkg;

    $self;
}

sub a {
    my ($self, @f) = @_;

    push @{ $self->{clause} }, [ @f ] ;
}

sub apl {
    my ($self, @p) = @_;
 
    $self->a($_) for @p;
}


sub satisfied {
    my ($self, @body) = @_;

    if ($debug) {
	warn sprintf "TESTING @body in satisfied() with self-e: %s",
      Data::Dumper::Dumper($self->{established});
    }

    for my $prop (@body) {
	if ($debug) {
	    warn sprintf "prop($prop): %s dr: %s dr2: %s dump: %s",
	    $prop, 
	    $self->{established}->{$prop}, 
	    $self->{established}->{intro_req}, 
	  Data::Dumper::Dumper($self->{established});
	}
	if ($self->{established}->{$prop}) {
	    next;
	} else {
	    warn "$prop NOT established.. $self->{established}->{$prop}" 
		if $debug;
	    return 0;
	}
    }
    warn "all @body satisfied..." if $debug;
    return 1;
}

sub top_down {
    my ($self, @goal_list) = @_;

    warn "GL: @goal_list" if $debug;

    return 1 if (not scalar @goal_list);

    for my $clause (@{$self->{clause}}) {
	warn "testing @$clause" if $debug;

	if ($clause->[0] eq $goal_list[0]) {
	    warn "recursing on @$clause" if $debug;
	    return 1 if ($self->top_down(@$clause[1..$#$clause]),
			 @goal_list[1 .. $#goal_list]);
	}
    }

    return 0;

}

sub bottom_up {
    my ($self, @goal_list) = @_;

    warn "GOAL_LIST: @goal_list" if $debug;

    $self->{established} = {};

    my $iter_count = 0;

    {
	my @new_list = ();

	for my $clause (@{$self->{clause}}) {

#	    $debug = 1 if ($clause->[0] eq 'basic_cs');

	    if ($self->satisfied(@$clause[1..$#$clause])) {
		warn sprintf "%s satisfied", $clause->[0] if $debug;
		push @new_list, $clause->[0] 
		    unless ($self->{established}->{$clause->[0]})
			or 
			    (scalar grep { $clause->[0] eq $_ } @new_list);
	    }

	    $debug = 0;
	}

	++$self->{established}->{$_} for @new_list;    

	redo if @new_list;
    }

#    warn Data::Dumper->Dump([$self,\@goal_list],['self','goal_list']);

#    warn "NOW WE TEST @goal_list";
    
    $self->satisfied(@goal_list);

}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

AI::Proplog - Propositional logic engine

=head1 SYNOPSIS

 use strict;
 use AI::Proplog;
 
 my $p = new AI::Proplog;
 #
 # assert some facts:
 #
 
 # cs requirements are basic cs, math, advanced cs, an engr rec and nat. sci.
 $p->a( cs_req => qw(basic_cs math_req advanced_cs engr_rec natural_science));
 
 # basic cs requires an intro req, comp org, advanced programming and theory
 $p->a( basic_cs  => qw(intro_req comp_org adv_prog theory) );
 
 # and so forth
 $p->a( intro_req => 'intro_cs');
 $p->a( intro_req => qw(introI introII) );
 $p->a( math_req  => qw(calc_req finite_req alg_req) );
 $p->a( calc_req  => qw(basic_calc adv_calc) );
 $p->a( basic_calc => qw(calcI calcII) );
 $p->a( basic_calc => qw(calcA calcB calcC) );
 $p->a( adv_calc   => 'lin_alg');
 $p->a( adv_calc   => 'honors_linalg');
 $p->a( finite_req => qw(fin_structI stat) );
 $p->a( alg_req    => 'fin_structII');
 $p->a( alg_req    => 'abs_alg');
 $p->a( alg_req    => 'abs_alg');
 
 # here we assert a bunch of facts:
 
 # the following things have been taken:
 # cs intro, computer org, advanced programming, and theory
 $p->apl( qw(intro_cs comp_org adv_prog theory) );
 
 # now do a bottom up search of the fact/rule space to see if the 
 # basic cs requirements have been met
 my $R = $p->bottom_up('basic_cs');
# or:  my $R = $p->top_down('basic_cs');
 ok($R);

=head1 DESCRIPTION

This module is a prelude to more powerful modules supporting predicate
and functional logic semantics with Perl syntax. The search algorithms
are naive, inefficient and not-foolproof. For example the top-down
engine will run without termination on the following code:

    $p->a( x => 'y' );
    $p->a( y => 'x' );

On the other hand, the code body is quite small (smaller than the
original Pascal examples in the textbook) and thus serves as an
excellent vehicle for study of such programs.

It is written based on the same interpreters described in "Computer
with Logic: Logic Programming with Prolog", a book by David Maer and
David S. Warren.

=head1 USAGE

First you C<use AI::Proplog> then you assert rules and facts using
C<a()>. If you have a bunch of facts you want to assert, you can do so
conveniently with C<apl()> as exmplified in the SYNOPSIS. 

Then you search your universe of truths in a top down or bottom-up
manner, depending on what you want to do with the results. If you
would like to know every truth that can result from your fact/rule
space, then use C<bottom_up> and inspect C<$p->{established}> with
Data::Dumper to see all the derived propositions.

On the other hand, if you are more interested in simply finding out if
a certain proposition holds based on the fact/rule base, then
C<top_down()> will likely be more efficient. This is because it will
terminate as soon as a proposition is derived which matches your one
of interest. However, C<top_down()> does do backtracking, while
C<bottom_up()> simply plows through your fact/rule base one time
finding every truth it can, and then testing your queried
proposition. 

=head1 TODO

=head2 Probablistic propositions:

 # there is a 0.6 chance that a souffle rises is beaten well and it is quiet
    $p->a( souffle_rises(0.6) => qw(beaten_well quiet_while_cooking) ) ;

 # there is a 0.1 chance that it will rise based on luck
    $p->a( souffle_rise(0.1 ) => 'have_luck');

 # there is thus 0.3 chance that it will NOT rise 

    $p->a( beaten_well(0.4)   => 'use_whisk');
    $p->a( beaten_well(0.6)   => 'use_mixer');

    $p->a( quiet_while_cooking(0.8) => 'kids_outside');
    $p->a( have_luck(0.3) => 'knock_on_wood');
 
 # tell me what the chances are of this souffle rising if the kids are
 # outside and I use whisk...
    $p->apl( qw(use_whisk kids_outside) );

 $p->top_down('souffle_rise')

=head2 use strict terms

Right now if a single term shows up there is no warning, thus if I
mis-spell a term name (as I did when making the test suite for this),
then the program will search for something that no-one intended it to.

=head1 AUTHOR

T. M. Brannon, <tbone@cpan.org>

I would like to thank nardo and IDStewart of www.perlmonks.org for
their help in debugging my test suite for me. I would have never got
this module out so fast if it weren't for thie speedy help.

=head1 SEE ALSO

=over 4

=item * "Computer with Logic: Logic Programming with Prolog", a book by David Maer and David S. Warren

=item * Array::PatternMatcher

=item * Quantum::Superpositions

=item * Quantum::Entanglements

=back

=cut
