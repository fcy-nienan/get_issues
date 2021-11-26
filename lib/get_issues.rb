require "json"
require "spreadsheet_architect"

module GetIssues
  class Error < StandardError; end

  def self.start_group(prefix_url,private_token,group_name,mile_stone_title)
    groups_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/groups?per_page=1000"`
    groups_json = JSON.parse(groups_string)
    group_json = groups_json.filter { |t| t["name"] == group_name }&.first || {}
    group_id = group_json["id"]
    if group_id.nil?
      p "找不到group"
    end

    milestones_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/groups/#{group_id}/milestones?per_page=1000"`
    milestones_json = JSON.parse(milestones_string)
    mile_stone_json = milestones_json.filter { |t| t["title"] == mile_stone_title }&.first
    mile_stone_id = mile_stone_json["id"]
    if mile_stone_id.nil?
      p "找不到mile_stone"
    end

    issues_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/groups/#{group_id}/milestones/#{mile_stone_id}/issues?per_page=10000"`
    issues_json = JSON.parse(issues_string)
    issues_json
  end

  def self.start_project(prefix_url, private_token, project_name, mile_stone_title)
    projects_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/projects?sort=asc&&order_by=name&&simple=true&&per_page=1000"`
    projects_json = JSON.parse(projects_string)
    project_json = projects_json.filter { |t| t["name"] == project_name }&.first || {}
    project_id = project_json["id"]
    if project_id.nil?
      p "找不到project"
    end
    milestones_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/projects/#{project_id}/milestones?per_page=1000"`
    milestones_json = JSON.parse(milestones_string)
    mile_stone_json = milestones_json.filter { |t| t["title"] == mile_stone_title }&.first || {}
    mile_stone_id = mile_stone_json["id"]
    if mile_stone_id.nil?
      p "找不到mile_stone"
    end
    issues_string = `curl --header "PRIVATE-TOKEN: #{private_token}" "#{prefix_url}/projects/#{project_id}/milestones/#{mile_stone_id}/issues?per_page=10000"`
    issues_json = JSON.parse(issues_string)
    issues_json
  end

  def self.to_xlsx(issues_json,mile_stone_title)
    data = []
    issues_json.each do |issue|
      assignes_names = issue["assignees"]&.map { |t| t["name"]&.split(" ")&.reverse&.join("") }&.join(",")
      milestone = issue["milestone"]["title"] rescue ""
      data << ["##{issue["iid"]}",issue["title"], assignes_names, issue["labels"]&.join(","), milestone]
    end
    headers = %w(编号 标题 负责人 标签 归属端)
    options = { headers: headers, data: data, header_style: init_header_style, row_style: init_row_style }
    file_data = SpreadsheetArchitect.to_xlsx(options)
    file = File.open("#{mile_stone_title}.xlsx".to_s, "wb+") do |f|
      f.write file_data
    end
  end
  def self.to_xlsx_group(prefix_url,private_token,group_name,mile_stone_title)
    issues_json = start_group(prefix_url,private_token,group_name,mile_stone_title)
    to_xlsx(issues_json,mile_stone_title)
  end
  def self.to_xlsx_project(prefix_url, private_token, project_name, mile_stone_title)
    issues_json = start_project(prefix_url, private_token, project_name, mile_stone_title)
    to_xlsx(issues_json,mile_stone_title)
  end
  # 定义xlsx文件格式的头样式
  def self.init_header_style
    { height: 75, background_color: "458B00", color: "FFFFFF", align: :center, font_name: "Arial", font_size: 14, bold: false, italic: false, underline: false }
  end

  # 定义xlsx文件的row样式
  def self.init_row_style
    { font_size: 12, align: :left }
  end
end
