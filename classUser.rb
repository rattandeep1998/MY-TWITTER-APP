class User
	include DataMapper::Resource
	property :userId ,Serial
	property :name ,String
	property :email ,String
	property :password ,String
end