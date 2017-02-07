class Tweet
	include DataMapper::Resource
	property :tweetId ,Serial
	property :content ,String
	property :likes ,Integer
	property :dislikes, Integer
	property :userId ,Integer


end