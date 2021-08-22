require 'json'

module GetIssues
  class Error < StandardError; end
  def self.start(prefix_url,private_token,group_name,project_name,mile_stone_title)
    projects_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}"`
    projects_json = JSON.parse(projects_string)
    project_json = projects_json.filter{|t| t["name"]==project_name}&.first
    project_id = project_json["id"]
    

    milestones_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/#{project_id}/milestones"`
    milestones_json = JSON.parse(milestones_string)
    mile_stone_json = milestones_json.filter{|t| t["title"]==milestone_title}&.first
    mile_stone_id = mile_stone_json["id"]


    issues_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/#{project_id}/milestones/#{mile_stone_id}/issues"`
    issues_json = JSON.parse(issues_string)
  end
end
