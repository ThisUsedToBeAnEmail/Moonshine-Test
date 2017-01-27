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
            test => 'render_me',
            instance => $instance,
            function => 'p',
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

done_testing();

1;
