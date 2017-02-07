class Comment
	include DataMapper::Resource
	property :commentId ,Serial
	property :content ,String
	property :tweetId ,Integer
	property :userId ,Integer
	
end