url            = require('url')
querystring    = require('querystring')
actionTypes    = ['opened', 'synchronize', 'reopened']
eventTypes     = ['pull_request']

bamboo_user = process.env.bamboo_user
bamboo_pass = process.env.bamboo_pass
github_api_token = process.env.github_api_token

module.exports = (robot) ->
  robot.router.post "/hubot/trigger-bamboo", (req, res) ->

    # Extract Bamboo plan variables from query url 
    query = querystring.parse(url.parse(req.url).query)
    bamboo_url = query.bamboo
    build_key = query.buildKey
    if !bamboo_url? or !build_key?
      console.log "Bad request. Missing parameters in query string"
      res.writeHead 400
      res.end "Missing parameters in query string\n"
      return

    # Extract pull request info from webhook headers and payload
    payload = req.body
    actionType = payload.action
    eventType = req.headers["x-github-event"]

    try
      if eventType in eventTypes && actionType in actionTypes
        
        # Webhook was generated by valid pull request. Attempt to queue Bamboo PR build
        console.log "Processing #{eventType} event in repo #{payload.pull_request.html_url}. Action: #{actionType}"
        robot.http("#{bamboo_url}/rest/api/latest/queue/#{build_key}?" +
                   "bamboo.variable.pull_ref=#{payload.pull_request.head.ref}&" +
                   "bamboo.variable.pull_sha=#{payload.pull_request.head.sha}&" +
                   "bamboo.variable.pull_num=#{payload.number}&" +
                   "bamboo.variable.git_repo_url=#{payload.repository.clone_url}")
          .auth(bamboo_user, bamboo_pass)
          .header('Accept', 'application/json')
          .post() (err, res, body) ->
            if err
              console.log "Encountered an error :( #{err}"
            else
              json_body = JSON.parse body
                
              # Determine whether build was successfully queued and update GitHub PR status accordingly
              if !json_body.hasOwnProperty("status-code")
                robot.http(payload.pull_request.statuses_url)
                  .header('Authorization', "token #{github_api_token}")
                  .post('{"state": "pending", "context": "bamboo", "description": "A Bamboo build has been queued", "target_url": "' +
                        "#{bamboo_url}/browse/#{json_body.buildResultKey}\"}")
              else
                console.log body
                robot.http(payload.pull_request.statuses_url)
                  .header('Authorization', "token #{github_api_token}")
                  .post('{"state": "failure", "context": "bamboo", "description": "' + "#{json_body.message}" + '", "target_url": "' + 
                        "#{bamboo_url}/browse/#{json_body.buildResultKey}\"}")
      else if eventType not in eventTypes
        console.log "Ignoring #{eventType} event in repo #{payload.pull_request.html_url}. Only pull_request events are handled"
      else
        console.log "Pull request #{payload.pull_request.html_url} was #{actionType}. Ignoring event as no code changes were made"
    catch error
      console.log "github repo event notifier error: #{error}. Request: #{req.body}"

    res.end "okay"
