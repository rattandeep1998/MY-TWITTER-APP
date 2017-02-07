class Tag
	include DataMapper::Resource
	property :tagId ,Serial
	property :taggedBy ,Integer
	property :taggedTo ,Integer
	property :tweetId ,Integer
end