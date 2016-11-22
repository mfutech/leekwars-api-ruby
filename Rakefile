TAG=Time.new.strftime('%Y%m%dx%H%M')
NAME='mfutech/leekwarstools'
FULLTAG="#{NAME}:#{TAG}"
IMAGE='Z:/Docker/Image-LeekWarsTools.tgz'

task :default => [ 
	:save,
	]
 
task :build do 
	out = %x[docker build -t #{FULLTAG} . ]
	r = out.match(/Successfully built (.*)$/)
	puts r
end

task :save => :build do
	%x[docker save -o #{IMAGE} #{FULLTAG}]
end

task :push => :build do
	puts "do no use"
	#%x[docker push #{FULLTAG}]
end
