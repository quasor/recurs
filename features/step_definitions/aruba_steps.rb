require 'aruba/api'
#require 'aruba/cucumber'
#=begin
World(Aruba::Api)

Before('@disable-bundler') do
  unset_bundler_env_vars
end

Before do
  @__aruba_original_paths = (ENV['PATH'] || '').split(File::PATH_SEPARATOR)
  ENV['PATH'] = ([File.expand_path('bin')] + @__aruba_original_paths).join(File::PATH_SEPARATOR)
end

After do
  ENV['PATH'] = @__aruba_original_paths.join(File::PATH_SEPARATOR)
end

Before do
  FileUtils.rm_rf(current_dir)
end

Before('@puts') do
  @puts = true
end

Before('@announce-cmd') do
  @announce_cmd = true
end

Before('@announce-stdout') do
  @announce_stdout = true
end

Before('@announce-stderr') do
  @announce_stderr = true
end

Before('@announce-dir') do
  @announce_dir = true
end

Before('@announce-env') do
  @announce_env = true
end

Before('@announce') do
  @announce_stdout = true
  @announce_stderr = true
  @announce_cmd = true
  @announce_dir = true
  @announce_env = true
end

After do
  restore_env
end

Given /^I'm using a clean gemset "([^"]*)"$/ do |gemset|
  use_clean_gemset(gemset)
end

Given /^a directory named "([^"]*)"$/ do |dir_name|
  create_dir(dir_name)
end

Given /^a file named "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

Given /^an empty file named "([^"]*)"$/ do |file_name|
  create_file(file_name, "")
end

When /^I write to "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, false)
end

When /^I overwrite "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content, true)
end

When /^I append to "([^"]*)" with:$/ do |file_name, file_content|
  append_to_file(file_name, file_content)
end

When /^I remove the file "([^"]*)"$/ do |file_name|
  remove_file(file_name)
end

When /^I cd to "([^"]*)"$/ do |dir|
  cd(dir)
end

When /^I run "(.*)"$/ do |cmd|
  run_simple(unescape(cmd), false)
#  sleep(5)
end

When /^I successfully run "(.*)"$/ do |cmd|
  run_simple(unescape(cmd))
end

When /^I run "([^"]*)" interactively$/ do |cmd|
  run_interactive(unescape(cmd))
end

When /^I type "([^"]*)"$/ do |input|
  write_interactive(ensure_newline(input))
end

Then /^the output should contain "([^"]*)"$/ do |partial_output|
  assert_partial_output(unescape(partial_output))
end

Then /^the output from "([^"]*)" should contain "([^"]*)"$/ do |cmd, partial_output|
  output_from(cmd).should include(unescape(partial_output))
end

Then /^the output from "([^"]*)" should not contain "([^"]*)"$/ do |cmd, partial_output|
  output_from(cmd).should_not include(unescape(partial_output))
end

Then /^the output should not contain "([^"]*)"$/ do |partial_output|
  all_output.should_not include(unescape(partial_output))
end

Then /^the output should contain:$/ do |partial_output|
  all_output.should include(unescape(partial_output))
end

Then /^the output should not contain:$/ do |partial_output|
  all_output.should_not include(unescape(partial_output))
end

Then /^the output should contain exactly "([^"]*)"$/ do |exact_output|
  all_output.should == unescape(exact_output)
end

Then /^the output should contain exactly:$/ do |exact_output|
  all_output.should == unescape(exact_output)
end

# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the output should match \/([^\/]*)\/$/ do |partial_output|
  all_output.should =~ /#{partial_output}/
end

Then /^the output should match:$/ do |partial_output|
  all_output.should =~ /#{partial_output}/m
end

Then /^the exit status should be (\d+)$/ do |exit_status|
  @last_exit_status.should == exit_status.to_i
end

Then /^the exit status should not be (\d+)$/ do |exit_status|
  @last_exit_status.should_not == exit_status.to_i
end

Then /^it should (pass|fail) with:$/ do |pass_fail, partial_output|
  self.__send__("assert_#{pass_fail}ing_with", partial_output)
end

Then /^it should (pass|fail) with exactly:$/ do |pass_fail, exact_output|
  assert_exit_status_and_output(pass_fail == "pass", exact_output, true)
end

Then /^it should (pass|fail) with regexp?:$/ do |pass_fail, partial_output|
  Then "the output should match:", partial_output
  if pass_fail == 'pass'
    @last_exit_status.should == 0
  else
    @last_exit_status.should_not == 0
  end
end

Then /^the stderr should contain "([^"]*)"$/ do |partial_output|
  all_stderr.should include(unescape(partial_output))
end

Then /^the stderr should contain exactly:$/ do |exact_output|
  all_stderr.should == exact_output
end

Then /^the stdout should contain "([^"]*)"$/ do |partial_output|
  all_stdout.should include(unescape(partial_output))
end

Then /^the stdout should contain exactly:$/ do |exact_output|
  all_stdout.should == exact_output
end

Then /^the stderr should not contain "([^"]*)"$/ do |partial_output|
  all_stderr.should_not include(unescape(partial_output))
end

Then /^the stdout should not contain "([^"]*)"$/ do |partial_output|
  all_stdout.should_not include(unescape(partial_output))
end

Then /^the stdout from "([^"]*)" should contain "([^"]*)"$/ do |cmd, partial_output|
  stdout_from(cmd).should include(unescape(partial_output))
end

Then /^the stdout from "([^"]*)" should not contain "([^"]*)"$/ do |cmd, partial_output|
  stdout_from(cmd).should_not include(unescape(partial_output))
end

Then /^the stderr from "([^"]*)" should contain "([^"]*)"$/ do |cmd, partial_output|
  stderr_from(cmd).should include(unescape(partial_output))
end

Then /^the stderr from "([^"]*)" should not contain "([^"]*)"$/ do |cmd, partial_output|
  stderr_from(cmd).should_not include(unescape(partial_output))
end

Then /^the file "([^"]*)" should not exist$/ do |file_name|
  check_file_presence([file_name], false)
end

Then /^the following files should exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end

Then /^the following files should not exist:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end

Then /^a file named "([^"]*)" should exist$/ do |file|
  check_file_presence([file], true)
end

Then /^a file named "([^"]*)" should not exist$/ do |file|
  check_file_presence([file], false)
end

Then /^the following directories should exist:$/ do |directories|
  check_directory_presence(directories.raw.map{|directory_row| directory_row[0]}, true)
end

Then /^the following directories should not exist:$/ do |directories|
  check_directory_presence(directories.raw.map{|directory_row| directory_row[0]}, false)
end

Then /^a directory named "([^"]*)" should exist$/ do |directory|
  check_directory_presence([directory], true)
end

Then /^a directory named "([^"]*)" should not exist$/ do |directory|
  check_directory_presence([directory], false)
end

Then /^the file "([^"]*)" should contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end

Then /^the file "([^"]*)" should not contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(file, partial_content, false)
end

Then /^the file "([^"]*)" should contain exactly:$/ do |file, exact_content|
  check_exact_file_content(file, exact_content)
end

Then /^the migration file create_"([^"]*)"s.rb should contain exactly:$/ do |file, exact_content|
  found = Dir.entries("#{current_dir}/db/migrate").select {|f| f if f.match(/\n*_create_#{file}s.rb/) }
  check_exact_file_content("#{current_dir}/db/migrate/#{found.first}", exact_content)
end

Then /^the file that's name includes "([^"]*)" in "([^"]*)" should contain exactly:$/ do |file, folder, exact_content|
  found = Dir.entries("#{current_dir}/#{folder}").select {|f| f if f.match(/\S*#{file}\S*/) }
  check_exact_file_content("#{current_dir}/#{folder}/#{found.first}", exact_content)
end

Then /^the file "([^"]*)" should match \/([^\/]*)\/$/ do |file, partial_content|
  check_file_content(file, /#{partial_content}/, true)
end

Then /^the file "([^"]*)" should not match \/([^\/]*)\/$/ do |file, partial_content|
  check_file_content(file, /#{partial_content}/, false)
end

#=end