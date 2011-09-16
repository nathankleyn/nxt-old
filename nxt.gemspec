Gem::Specification.new do |spec|
  spec.name = 'nxt'
  spec.version = '0.0.1'
  spec.extra_rdoc_files = ['README.markdown']
  spec.summary = ''
  spec.description = spec.summary + ' See http://github.com/nathankleyn/nxt for more information.'
  spec.author = 'Nathan Kleyn'
  spec.email = 'nathan@unfinitydesign.com'
  spec.homepage = 'http://github.com/nathankleyn/nxt'
  spec.files = %w(README.markdown Rakefile) + Dir.glob("{lib,spec}/**/*")
  spec.require_path = "lib"
  
  spec.add_development_dependency("rspec", "~>2.6.0")
end
