# Description:
#   cat me is the most important thing in life
#
# Dependencies:
#
# Configuration:
#   HUBOT_THE_CAT_API_KEY -
#     Obtained from http://thecatapi.com/api-key-registration.html
#
# Commands:
#   hubot cat me - Receive a cat
#   hubot cat bomb N - Get N cats
#   hubot cat categories - List all available categories
#   hubot cat (with|in) category -
#         Receive a cat in the given category (use index number for now)
api_key = process.env.HUBOT_THE_CAT_API_KEY
cat_search_url = "https://api.thecatapi.com/v1/images/search"

module.exports = (robot) ->

  robot.respond /cat( me)?$/i, (msg) ->
    authenticated_msg msg, "#{cat_search_url}"
      .get() (err, res, body) ->
        msg.send (JSON.parse body)[0]['url']

  robot.respond /cat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    count = 25 if count > 25
    authenticated_msg msg, "#{cat_search_url}?limit=#{count}"
      .get() (err, res, body) ->
        msg.send cat['url'] for cat in (JSON.parse body)

# TODO: put that in the brain
  robot.respond /cat categories/i, (msg) ->
    authenticated_msg msg, "https://api.thecatapi.com/v1/categories"
      .get() (err, res, body) ->
        msg.send "#{category['id']}: #{category['name']}" for category in (JSON.parse body)

  robot.respond /cat( me)? (with|in)( (\w+))?/i, (msg) ->
    category = msg.match[3] || '15' #clothes
    authenticated_msg msg, "#{cat_search_url}?category_ids="+category.trim()
      .get() (err, res, body) ->
        response = JSON.parse body
        if response.length
          msg.send response[0]['url']
        else
          msg.send 'Enter a valid category (type "cat categories")'

authenticated_msg = (msg, url) ->
  msg.http(url).header('x-api-key', "#{api_key}")
