class Follower
	include DataMapper::Resource
	property :followerId ,Serial
	property :followedBy ,Integer
	property :followedTo ,Integer
end