use Test::Tester;

use Moonshine::Test qw/:all/;
use Test::MockObject;

(my $element = Test::MockObject->new)
    ->set_isa('Moonshine::Element');

$element->mock('render', sub { 
    my $args = $_[1]; 
    my $tag = delete $args->{tag};  
    my $text = delete $args->{data} // '';
    my $attributes = '';
    map {$attributes .= ' ';$attributes .= sprintf( '%s="%s"', $_, $args->{$_} );} keys %{ $args };
    return sprintf('<%s%s>%s</%s>', $tag, $attributes, $text, $tag);
}); 

(my $instance = Test::MockObject->new)->set_isa('Moonshine::Component');

$instance->mock('p', sub { my $args = $_[1]; 
    return (Test::MockObject->new)->mock('render', sub { $element->render({tag => 'p', %{$args} }) }) 
});

(my $div = Test::MockObject->new)->set_isa('Moonshine::Element');
$div->mock('render', sub { $element->render({tag => 'div', class => 'test', data => 'test' }) }); 

$instance->mock('broken', sub { my $args = $_[1]; 
    return (Test::MockObject->new)->mock('render', sub { $element->render({%{$args}}) }) 
});

check_test(
    sub {
        moon_test_one(
            test => 'render',
            instance => $instance,
            func => 'p',
            args => {
                data => 'test',
            },
            expected => '<p>test</p>'
        );
    },
    {
        ok => 1,
        name => "render instance: <p>test</p>",
        depth => 3,
        completed => 1,
    },
    'test render_me(p)'
);

my $arrayref = [ { name => 'one' }, { name => 'two' } ];
$instance->mock('arrayref', sub { return $arrayref });

check_test(
    sub {
        moon_test_one(
            test => 'ref',
            instance => $instance,
            func => 'arrayref',
            expected => $arrayref,
        );
    },
    {
        ok => 1,
        name => "function: arrayref is ref - is_deeply",
        depth => 2,
        completed => 1,
    },
    'test mocked arrayref function'
);

my $hashref = { name => 'one', second => 'two' };
$instance->mock('hashref', sub { return $hashref });

check_test(
    sub {
        moon_test_one(
            test => 'ref',
            instance => $instance,
            func => 'hashref',
            expected => $hashref,
        );
    },
    {
        ok => 1,
        name => "function: hashref is ref - is_deeply",
        depth => 2,
        completed => 1,
    },
    'test mocked hashref function'
);

my @array = (qw/one two three/);
$instance->mock('array', sub { return @array });

check_test(
    sub {
        moon_test_one(
            test => 'array',
            instance => $instance,
            func => 'array',
            expected => [qw/one two three/],
        );
    },
    {
        ok => 1,
        name => "function: array is array - reference - is_deeply",
        depth => 2,
        completed => 1,
    },
    'test mocked array function'
);

my %hash = (map { $_ => 1 } qw/one two three/);
$instance->mock('hash', sub { return %hash });

check_test(
    sub {
        moon_test_one(
            test => 'hash',
            instance => $instance,
            func => 'hash',
            expected => \%hash,
        );
    },
    {
        ok => 1,
        name => "function: hash is hash - reference - is_deeply",
        depth => 2,
        completed => 1,
    },
    'test mocked hash function'
);

$instance->mock('obj', sub { return bless {}, 'Test::Moon'; });

check_test(
    sub {
        moon_test_one(
            test => 'obj',
            instance => $instance,
            func => 'obj',
            expected => 'Test::Moon',
        );
    },
    {
        ok => 1,
        name => "function: obj is Object - blessed - is - Test::Moon",
        depth => 2,
        completed => 1,
    },
    'test mocked obj function'
);

$instance->mock('catch', sub { die 'a horrible death'; });

check_test(
    sub {
        moon_test_one(
            catch => 1,
            instance => $instance,
            func => 'catch',
            expected => qr/a horrible death/,
        );
    },
    {
        ok => 1,
        name => "catch is like - (?^:a horrible death)",
        depth => 2,
        completed => 1,
    },
    'test mocked catch(die) function'
);

check_test(
    sub {
        moon_test_one(
            test => 'render',
            instance => $instance,
            func => 'broken',
            args => {
                class => 'test',
                data  => 'test',
            },
            expected => '<div class="test">test</div>'
        );
    },
    {
        ok => 0,
        name => "render instance: <div class=\"test\">test</div>",
        depth => 3,
        diag => "         got: '< class=\"test\">test</>'\n    expected: '<div class=\"test\">test</div>'"
    },
    'test broken()'
);

check_test(
    sub {
        moon_test_one(
            instance => $instance,
            func => 'hash',
            expected => \%hash,
        );
    },
    {
        ok => 0,
        diag => "No instruction{test} passed to moon_test_one",
        depth => 2,
    },
    'test no instruction'
);


$instance->mock('true', sub { return 1; });

check_test(
    sub {
        moon_test_one(
            test => 'true',
            instance => $instance,
            func => 'true',
        );
    },
    {
        ok => 1,
        name => "function: true is true - 1",
        depth => 2,
        completed => 1,
    },
    'test mocked true function'
);

$instance->mock('false', sub { return 0; });

check_test(
    sub {
        moon_test_one(
            test => 'false',
            instance => $instance,
            func => 'false',
        );
    },
    {
        ok => 1,
        name => "function: false is false - 0",
        depth => 2,
        completed => 1,
    },
    'test mocked false function'
);


sunrise(67, '*\o/*');

1;
