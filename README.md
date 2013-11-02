concerning-meta
===============

Rails 4 tries to make our codebases easier to read by bringing the idea of 'concerns' to the forefront.  Over-simply put, concerns give you a nice place to put shared code.  The best place to learn about it is from Mr. RoR himself, DHH - http://37signals.com/svn/posts/3372-put-chubby-models-on-a-diet-with-concerns

Let's talk about the right side of that hyphen - meta.

Meta-programming is a powerful beast.  It shreds your thoughts with claws of confusion, creating a milkshake-like concoction of consciousness, that then explodes.  An explosion caused in no small part by trying to debug problems in a large codebase that turn out to be related to meta-programming code gone wrong, then realizing you don't have a good way to find out where that code lives.

Of course this beast only rears its head in projects that have lived long enough to let the underbrush grow too much. (wow, this analogy is really working out, I feel like a controlled-burn point could be made here as well to point to the goodness of refactoring and reviewing, but I don't feel like it, so, there's this long parenthetical sentence).  Concerns offer a nice place to put this meta stuff, along with offering the goodnesses that DHH explained.  So let's get to it.

This project
------------

I believe in readability in a code base.  It naturally helps with on-boarding new people and maintainability in general.  What is more readable is sometimes debatable, but let's just pretend what I'm about to say is true.

`author.last_post.not_published?`

is more readable than

`!author.last_post.published?`

We all agree of course (right?), but that natural response is '**Well sure, but who wants to write all those additional methods?**'.  No one.  Not one person.  But we can't let something like that stop us.  That's where meta-programming, and specifically **method_missing**, shines.

method_missing and respond_to? are explained very well here: http://technicalpickles.com/posts/using-method_missing-and-respond_to-to-create-dynamic-methods/

Essentially a model calls a method that doesn't exist.  That fires method_missing, which is where we look at the method name and decide if we do in fact want to do something with it.  This is accomplished by using a reg-ex to see if the name looks like what we're looking for, 'not_*?' for example.

Once we've got that done we want to make sure our models know that they can indeed fire that method, so we simply put that same reg-ex in the respond_to? method.

The last thing we want to do is actually create the method on the class to avoid possible performance hits.

You'll see these three things done in the 'missing_methods.rb' file.  One thing to notice is that the **define_dynamic_not(new_method, method_to_not)** is defined as a Class level method as we want all instances of our models to have access to the methods.  It could just as easily be defined for specific instances, which is very useful when you're adding dynamic role based functionality to things.

TL;DR Console Output
--------------------

`Loading development environment (Rails 4.0.1)
irb(main):001:0> instance_a = MetaModel.new
=> #<MetaModel:0x007fa17c9b9400>
irb(main):002:0> instance_a.model?
=> true
irb(main):003:0> instance_a.not_model?
method missing :: not_model?
=> false
irb(main):004:0> instance_a.not_model?
=> false
irb(main):005:0> instance_b = MetaModel.new
=> #<MetaModel:0x007fa17c9c1600>
irb(main):006:0> instance_b.not_model?
=> false
irb(main):007:0> instance_b.not_awesome?
method missing :: not_awesome?
=> false
irb(main):008:0> instance_a.not_awesome?
=> false
irb(main):009:0> instance_a.this_does_not_exist?
method missing :: this_does_not_exist?
NoMethodError: undefined method 'this_does_not_exist?' for #<MetaModel:0x007fa17c9b9400>
	from /Users/ryan/concerning-meta/metatastic/app/models/concerns/missing_methods.rb:51:in 'method_missing'
	from (irb):9
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands/console.rb:90:in 'start'
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands/console.rb:9:in 'start'
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands.rb:62:in '<top (required)>'
	from bin/rails:4:in 'require'
	from bin/rails:4:in '<main>'
irb(main):010:0> instance_a.not_this_does_not_exist?
method missing :: not_this_does_not_exist?
method missing :: this_does_not_exist?
NoMethodError: undefined method 'this_does_not_exist?' for #<MetaModel:0x007fa17c9b9400>
	from /Users/ryan/concerning-meta/metatastic/app/models/concerns/missing_methods.rb:51:in 'method_missing'
	from (eval):2:in 'not_this_does_not_exist?'
	from /Users/ryan/concerning-meta/metatastic/app/models/concerns/missing_methods.rb:49:in 'method_missing'
	from (irb):10
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands/console.rb:90:in 'start'
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands/console.rb:9:in 'start'
	from /Library/Ruby/Gems/2.0.0/gems/railties-4.0.1/lib/rails/commands.rb:62:in '<top (required)>'
	from bin/rails:4:in 'require'
	from bin/rails:4:in '<main>'`

I hope you enjoyed reading this ironically meta-less README file, and I really hope you find this useful.

If you find any bugs or issues, or if you make improvements, please let me know so I may incorporate fixes/new code.

Thanks,

~ Ryan =]

(I used 37 hyphens in this README, so ya, you know that now)
