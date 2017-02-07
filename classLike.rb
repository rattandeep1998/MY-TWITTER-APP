class Like
	include DataMapper::Resource
	property :likeId ,Serial
	property :tweetId ,Integer
	property :userId ,Integer
end