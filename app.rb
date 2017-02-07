require 'sinatra'
require 'data_mapper'

set :bind, '0.0.0.0'
set :sessions,true

DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/data.db")

require_relative 'classTweet.rb'
require_relative 'classComment.rb'
require_relative 'classUser.rb'
require_relative 'classFollower.rb'
require_relative 'classLike.rb'
require_relative 'classTag.rb'

DataMapper.finalize
Follower.auto_upgrade!
Comment.auto_upgrade!
User.auto_upgrade!
Tweet.auto_upgrade!
Like.auto_upgrade!
Tag.auto_upgrade!

get '/' do
	redirect '/homepage'
end

get '/homepage' do
	puts "HelloInHOME"
	if session[:userid]
		redirect '/welcomepage'
	else
		puts "HELLOHIIIiiiiiiiii"
		redirect '/signin'
	end
end

get '/signin' do
	puts "Hello"
	allTweets = Tweet.all()
	erb :signin ,locals: {:allTweets => allTweets}
end

post '/signin' do
	nameOrEmail=params[:nameOrEmail]
	password=params[:password]

	record = User.all(:email=>nameOrEmail).first
	record1 = User.all(:name=>nameOrEmail).first
	
	if record
		if record.password==password
			session[:userid]=record.userId
			redirect '/welcomepage'
		else
			redirect '/signin'
		end
	elsif record1
		if record1.password==password
			session[:userid]=record1.userId
			redirect '/welcomepage'
		else
			redirect '/signin'
		end
	else
		redirect '/signin'
	end	
end

get '/signup' do
	erb :signup
end

post '/newuserentry' do
	username=params[:username]
	email=params[:email]
	password=params[:password]

	record = User.all(:email=>email).first
	record1 = User.all(:name=>username).first
	if record || record1
		redirect '/signup'
	else
		newuser = User.new
		newuser.name = username
		newuser.email = email
		newuser.password = password
		newuser.save
		session[:userid] = newuser.userId
		redirect '/welcomepage'
	end
end

post '/logout' do
	session[:userid]=nil
	redirect '/'
end

get '/welcomepage' do
	userid = session[:userid]

	currUser = User.get(userid)
	allTweets = Tweet.all()
	myTweets = Tweet.all(:userId => userid)

	displayTweets = []

	followedPersons = Follower.all(:followedBy => userid)
	followers = Follower.all(:followedTo => userid)

	allTweets.each do |tweetObject|
		currFollowedPerson = followedPersons.all(:followedTo => tweetObject.userId).first
		if currFollowedPerson
			displayTweets << tweetObject
		elsif tweetObject.userId == userid
			displayTweets << tweetObject
		end
	end

	erb :welcome , locals: {:currUser => currUser , :allTweets => allTweets , :displayTweets => displayTweets , :countFollowing =>followedPersons.count , :countFollowers => followers.count , :countMyTweets => myTweets.count}
end

post '/addtweet' do
	newTweet = Tweet.new
	newTweet.content = params[:tweetContent]
	newTweet.likes = 0
	newTweet.dislikes = 0
	newTweet.userId = session[:userid]
	newTweet.save
	redirect '/welcomepage'
end

get '/liketweet/:tweetId' do
	currUserId = session[:userid]
	if currUserId
		currTweetId = params[:tweetId]
		currTweet = Tweet.get(currTweetId)
		likeOnCurrTask = Like.all(:tweetId => currTweetId)
		likeByCurrUser = likeOnCurrTask.all(:userId => currUserId).first
		if likeByCurrUser
			redirect '/welcomepage'
		else
			newLike = Like.new
			newLike.tweetId = currTweetId
			newLike.userId = currUserId
			newLike.save

			currTweet.likes += 1
			currTweet.save

			redirect '/welcomepage'
		end
	else
		redirect '/signin'
	end
end

get '/disliketweet/:tweetId' do
	currUserId = session[:userid]
	if currUserId
		currTweetId = params[:tweetId]
		currTweet = Tweet.get(currTweetId)
		likeOnCurrTask = Like.all(:tweetId => currTweetId)
		likeByCurrUser = likeOnCurrTask.all(:userId => currUserId).first

		likeByCurrUser.destroy
		currTweet.likes -= 1
		currTweet.save
		redirect '/welcomepage'
	else
		redirect '/signin'
	end
end

get '/selfprofile' do

	userid = session[:userid]

	currUser = User.get(userid)
	myTweets = Tweet.all(:userId => userid)
	followedPersons = Follower.all(:followedBy => userid)
	followers = Follower.all(:followedTo => userid)
	erb :selfprofile , locals: {:currUser => currUser , :myTweets => myTweets , :following =>followedPersons , :followers => followers}

end

get '/listoflikes/:tweetId' do

	currTweetId = params[:tweetId]
	#currTweet = Tweet.get(currTweetId)
	listOfLikes = Like.all(:tweetId => currTweetId)

	erb :listoflikes, locals: {:listOfLikes => listOfLikes}
end


#get '/listofdislikes/:tweetId' do
#	currTweetId = params[:tweetId]
#	#currTweet = Tweet.get(currTweetId)
#	listOfDislikes = Dislike.all(:tweetId => currTweetId)
#	erb :listofdislikes, locals: {:listOfDislikes => listOfDislikes}
#end

get '/deletetweet/:tweetId' do
	currTweetId = params[:tweetId]
	allLikes = Like.all(:tweetId => currTweetId)
	allLikes.each do |likeObj|
		likeObj.destroy
	end

	tweetObj = Tweet.all(:tweetId => currTweetId).first
	tweetObj.destroy

	redirect '/selfprofile'
end

get '/edittweet/:tweetId' do
	currTweetId = params[:tweetId]
	currTweet = Tweet.get(currTweetId)
	erb :edittweet, locals: {:currTweet => currTweet}
end

post '/edittweet' do
	newContent = params[:newContent]
	tweetId = params[:tweetId]
	tweet = Tweet.get(tweetId)
	tweet.update(:content => newContent)
	redirect '/selfprofile'
end

get '/profile/:userId' do
	puts "ssssssssssssssssssssssssssssssssss",session[:userid].class
	userId = params[:userId].to_i
	puts "blalbalalbablalbalblaablablabbalbaabalblalalbalbablablb",userId.class
	if session[:userid]
		if session[:userid]==userId
			redirect '/selfprofile'
		else
			currUser = User.get(userId)
			puts "lalalalalalalalalalalalalalalalaalalalalalalalalalala",currUser.class
			myTweets = Tweet.all(:userId => userId)
			followedPersons = Follower.all(:followedBy => userId)
			followers = Follower.all(:followedTo => userId)
			if session[:userid]
				if followers.all(:followedBy => session[:userid]).first
					isFollow = true
				else
					isFollow = false 
				end
			else
				isFollow = false
			end
			erb :profile , locals: {:isFollow => isFollow , :currUser => currUser , :myTweets => myTweets , :following =>followedPersons , :followers => followers}
		end
	else
		currUser = User.get(userId)
		myTweets = Tweet.all(:userId => userId)
		followedPersons = Follower.all(:followedBy => userId)
		followers = Follower.all(:followedTo => userId)
		if session[:userid]
			if followers.all(:followedBy => session[:userid]).first
				isFollow = true
			else
				isFollow = false 
			end
		else
			isFollow = false
		end
		erb :profile , locals: {:isFollow => isFollow , :currUser => currUser , :myTweets => myTweets , :following =>followedPersons , :followers => followers}
	end
end

post '/follow' do
	if session[:userid]
		firstUser = session[:userid]
		secondUser = params[:secondUser]
		puts "folowflwofwlofwolfwlwfofwolwfllfwowflfwlowoowflfwwlfo",secondUser.class
		newFollower = Follower.new
		newFollower.followedBy = firstUser
		newFollower.followedTo = secondUser
		newFollower.save
		para = "/profile/#{secondUser}"
		redirect para
	else
		redirect '/signin'
	end
end

post '/unfollow' do
	if session[:userid]
		firstUser = session[:userid]
		secondUser = params[:secondUser]
		record = Follower.all(:followedBy => firstUser)
		recordToBeDeleted = record.all(:followedTo => secondUser).first
		recordToBeDeleted.destroy
		para = "/profile/#{secondUser}"
		redirect para
	else
		redirect '/signin'
	end
end

post '/addcomment' do
	content = params[:commentContent]
	tweetId = params[:tweetId]
	newComment = Comment.new
	newComment.content = content
	newComment.tweetId = tweetId
	newComment.userId = session[:userid]
	newComment.save
	puts "commentcommentcommentcommentcommentcommentcommentcommentcomment",content.class
	puts content
	#CODE FOR TAGGING ANOTHER PERSON
	taggedPerson = User.all(:name => content).first
	#puts "taggedtaggedtaggedtaggedtaggedtagged",taggedPerson.name
	if taggedPerson
		userIdOfTaggedPerson = taggedPerson.userId
		newTag = Tag.new
		newTag.taggedBy = session[:userid]
		newTag.taggedTo = userIdOfTaggedPerson
		newTag.tweetId = tweetId
		newTag.save
	end

	redirect '/welcomepage'
end

post '/searchperson' do
	personName = params[:personName]
	person = User.all(:name => personName).first
	if person
		link = "/profile/#{person.userId}"
		redirect link
	else
		redirect '/'
	end
end

get '/showtweet/:tagId' do

	tagId = params[:tagId]
	currTag = Tag.get(tagId)
	currTweetId = currTag.tweetId
	currTag.destroy

	erb :showtweet, locals: {:currTweetId => currTweetId}
end
