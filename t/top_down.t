use strict;
use Test;

use AI::Proplog;
use Data::Dumper;

BEGIN { plan tests => 1 }

my $p = new AI::Proplog;

$p->a( cs_req => qw(basic_cs math_req advanced_cs engr_rec natural_science));
$p->a( basic_cs  => qw(intro_req comp_org adv_prog theory) );
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

$p->apl( qw(intro_cs comp_org adv_prog theory) );


my $R = $p->top_down('basic_cs');
ok($R);



