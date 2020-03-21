begin
	redisurl=Rails.env.production? ? "redis://redis:6379" : "redis://redis:6379"
	Resque.redis = Rails.env.production? ? 'redis:6379' : 'redis:6379'
	puts "redis url is: "+redisurl
	REDIS = Redis.new(url: redisurl)
	REDIS.flushall
rescue
	"warning: redis not enabled"
end