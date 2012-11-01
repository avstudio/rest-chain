# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch(%r{^lib/.+\.rb$})
  watch(%r{^lib/rest-chain/.+\.rb$})
  watch(%r{^lib/rest-chain/api/.+\.rb$})
  watch(%r{^lib/rest-chain/adapters/.+\.rb$})
  watch(%r{^lib/rest-chain/core/.+\.rb$})
  watch(%r{^lib/rest-chain/definitions/.+\.rb$})
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{^spec/support/.+\.rb$})
end
