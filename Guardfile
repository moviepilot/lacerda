# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard :bundler do
  watch('Gemfile')
  # Uncomment next line if your Gemfile contains the `gemspec' command.
  watch(/^.+\.gemspec/)
end

guard 'ctags-bundler', :src_path => ["lib"] do
  watch(/^(app|lib|spec\/support)\/.*\.rb$/)
  watch('Gemfile.lock')
  watch(/^.+\.gemspec/)
end

guard :rspec, cmd: 'rspec', all_on_start: true  do
  watch(%r{^spec/support/.*\.mson$}) { "spec" }
  watch(%r{^spec/support/.*\.rb$}) { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r{^(spec/.+_spec\.rb)$}) { "spec" }
  watch(%r{^lib/(.+)\.rb$})     { "spec" }
end

