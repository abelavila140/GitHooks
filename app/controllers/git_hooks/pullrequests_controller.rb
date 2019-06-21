
module GitHooks
  class PullrequestsController < ApplicationController

    def label
      request.body.rewind
      request_payload = JSON.parse(request.body.read)
      
      # Get values from the parsed JSON that we'll need as arguments later on
      repo_modified    = request_payload["pull_request"]["head"]["repo"]["name"]
      action_done      = request_payload["action"]
      number           = request_payload["pull_request"]["number"]
      submitted_status = request_payload["review"]["state"]

      # If review request is approved on an active repo
      if action_done == "submitted" && submitted_status == "approved" && active_repos.include?(repo_modified)
        Http.remove_label(repo_modified, number, "Dev Review")
        Http.add_label(repo_modified, number, ["Dev Approved"]) 
        Http.add_label(repo_modified, number, ["QA Review"])        
      end
      
      # If review request is 'declined'
      if action_done == "submitted" && submitted_status == "changes_requested" && active_repos.include?(repo_modified)
        Http.remove_label(repo_modified, number, "Dev Review")
      end
      
      head :ok 
    end
  end
end