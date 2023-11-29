require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'roo'
require 'erb'
require 'fileutils'

THINGS_FILE_PATH = 'public/things.json'
ITEMS_FILE_PATH = 'public/items.json'
TEMPLATE_FILE_PATH = 'public/template.json'

def get_things(things_file_path)
  File.open(things_file_path) { |f| JSON.parse(f.read) }
end

def set_things(things_file_path, things)
  File.open(things_file_path, 'w') { |f| JSON.dump(things, f) }
end

def get_items(items_file_path)
  File.open(items_file_path) { |f| JSON.parse(f.read) }
end

def set_items(items_file_path, items)
  File.open(items_file_path, 'w') { |f| JSON.dump(items, f) }
end

def get_template(template_file_path)
  File.open(template_file_path) { |f| JSON.parse(f.read) }
end

def set_template(template_file_path, template)
  File.open(template_file_path, 'w') { |f| JSON.dump(template, f) }
end


def post_things(excel_things, things_erb, channels_erb)
  xlsx = Roo::Excelx.new("#{__dir__}/excel/#{excel_things}") # Excelファイルを指定
  row_count = xlsx.last_row # Excelの行数を確認
  variables = xlsx.row(1)
  values = xlsx.row(2)
  data = {} # Excelの1行目と2行目を対応付ける
  variables.each_with_index do |variable, index|
    data[variable] = values[index]
  end

  erb_template = ERB.new(File.read("#{__dir__}/template/#{things_erb}"), trim_mode: '-') # erbファイルを開く
  output = erb_template.result(binding) # erbファイルを書き換える
  File.open("#{__dir__}/template/create/created_thing.erb", 'w') { |file| file.write(output) } # 新しいファイルにoutputでの変更を書き換える

  if row_count >= 3
    (3..xlsx.last_row).each do |row_number|
      new_values = xlsx.row(row_number)
      new_data = {}
      variables.each_with_index do |variable, index|
        new_data[variable] = new_values[index]
      end
      new_erb_template = ERB.new(File.read("#{__dir__}/template/#{channels_erb}"), trim_mode: '-')
      new_output = new_erb_template.result(binding)
      File.open("#{__dir__}/template/create/created_channel.erb", 'w') { |file| file.write(new_output) }
      channel_erb = File.read("#{__dir__}/template/create/created_channel.erb")
      parent_erb = File.read("#{__dir__}/template/create/created_thing.erb")
      updated_content = parent_erb.gsub("here", channel_erb) # parent_erb内の"here"をchannel_erbに書き換える
      File.open("#{__dir__}/template/create/created_thing.erb", 'w') do |file|
        file.puts updated_content # created_thing.erbにupdated_contentでの変更を書き換える
      end
    end
  end

  parent_erb = File.read("#{__dir__}/template/create/created_thing.erb")
  remove_here = parent_erb.gsub("here", "") # parent_erb内の"here"を取り除く
  File.open("#{__dir__}/template/create/created_thing.erb", 'w') do |file|
    file.puts remove_here # created_thing.erbにremove_hereでの変更を書き換える
  end
  File.open("#{__dir__}/template/create/created_thing.erb", "r") do |input_file|
    File.open("#{__dir__}/template/create/fixed_thing.erb", "w") do |output_file|
      input_file.each_line do |line|
        output_file.write(line) unless line.strip.empty? # 空行以外を書き込み
      end
    end
  end
  FileUtils.cp("#{__dir__}/template/create/fixed_thing.erb", "/openhab/conf/things/#{data['thingID']}.things")
end

def delete_things(excel_things)
  xlsx = Roo::Excelx.new("#{__dir__}/excel/#{excel_things}") # Excelファイルを指定
  variables = xlsx.row(1)
  (2..xlsx.last_row).each do |row_number|
    values = xlsx.row(row_number)
    data = {}
    variables.each_with_index do |variable, index|
      data[variable] = values[index] # Excelの1行目とn行目を対応付ける
    end
    File.delete("/openhab/conf/things/#{data['thingID']}.things")
  end
end


def post_items(excel_items, items_erb)
  xlsx = Roo::Excelx.new("#{__dir__}/excel/#{excel_items}") # Excelファイルを指定
  variables = xlsx.row(1)
  (2..xlsx.last_row).each do |row_number|
    values = xlsx.row(row_number)
    data = {}
    variables.each_with_index do |variable, index|
      data[variable] = values[index] # Excelの1行目とn行目を対応付ける
    end
    erb_template = ERB.new(File.read("#{__dir__}/template/#{items_erb}")) # erbファイルを開く

    output = erb_template.result(binding) # erbファイルを書き換える
    File.open("/openhab/conf/items/#{data['itemID']}.items", 'w') { |file| file.write(output) } # 新しいファイルにoutputでの変更を書き換える
  end
end

def delete_items(excel_items)
  xlsx = Roo::Excelx.new("#{__dir__}/excel/#{excel_items}") # Excelファイルを指定
  variables = xlsx.row(1)
  (2..xlsx.last_row).each do |row_number|
    values = xlsx.row(row_number)
    data = {}
    variables.each_with_index do |variable, index|
        data[variable] = values[index] # Excelの1行目とn行目を対応付ける
    end

    File.delete("/openhab/conf/items/#{data['itemID']}.items")
  end
end


def post_template(title_template, content)
  template_file_name = title_template
  content_value = content
  File.open("#{__dir__}/template/#{template_file_name}.erb", 'w') do |file|
    file.write(content_value)
  end
end

def delete_template(title_template)
  file_name = title_template

  File.delete("#{__dir__}/template/#{file_name}.erb")
end

get '/' do
  erb :index
end





# get '/things' do
get '/things' do
  @things = get_things(THINGS_FILE_PATH)
  erb :'things/index'
end

get '/things/new' do
  erb :'things/new'
end

# get '/things/:id' do
post '/things' do
  title_things = params[:title_things]
  excel_things = params[:excel_things]
  things_erb = params[:things_erb]
  channels_erb = params[:channels_erb]

  things = get_things(THINGS_FILE_PATH)
  id = (things.keys.map(&:to_i).max + 1).to_s
  things[id] = { 'title_things' => title_things, 'excel_things' => excel_things, 'things_erb' => things_erb, 'channels_erb' => channels_erb }
  set_things(THINGS_FILE_PATH, things)

  post_things(excel_things, things_erb, channels_erb)

  redirect '/things'
end


get '/things/:id' do
  things = get_things(THINGS_FILE_PATH)
  @title_things = things[params[:id]]['title_things']
  @excel_things = things[params[:id]]['excel_things']
  @things_erb = things[params[:id]]['things_erb']
  @channels_erb = things[params[:id]]['channels_erb']
  erb :'things/show'
end

get '/things/:id/edit' do
  things = get_things(THINGS_FILE_PATH)
  @title_things = things[params[:id]]['title_things']
  @excel_things = things[params[:id]]['excel_things']
  @things_erb = things[params[:id]]['things_erb']
  @channels_erb = things[params[:id]]['channels_erb']
  erb :'/things/edit'
end

patch '/things/:id' do
  title_things = params[:title_things]
  excel_things = params[:excel_things]
  things_erb = params[:things_erb]
  channels_erb = params[:channels_erb]

  things = get_things(THINGS_FILE_PATH)
  things[params[:id]] = { 'title_things' => title_things, 'excel_things' => excel_things, 'things_erb' => things_erb, 'channels_erb' => channels_erb }
  set_things(THINGS_FILE_PATH, things)

  post_things(excel_things, things_erb, channels_erb)

  redirect "/things/#{params[:id]}"
end


delete '/things/:id' do
  excel_things = params[:excel_things]

  things = get_things(THINGS_FILE_PATH)
  things.delete(params[:id])
  set_things(THINGS_FILE_PATH, things)

  delete_things(excel_things)

  redirect '/things'
end









# get '/items' do
get '/items' do
  @items = get_items(ITEMS_FILE_PATH)
  erb :'items/index'
end

get '/items/new' do
  erb :'items/new'
end

# get '/items/:id' do
post '/items' do
  title_items = params[:title_items]
  excel_items = params[:excel_items]
  items_erb = params[:items_erb]

  items = get_items(ITEMS_FILE_PATH)
  id = (items.keys.map(&:to_i).max + 1).to_s
  items[id] = { 'title_items' => title_items, 'excel_items' => excel_items, 'items_erb' => items_erb}
  set_items(ITEMS_FILE_PATH, items)

  post_items(excel_items, items_erb)

  redirect '/items'
end


get '/items/:id' do
  items = get_items(ITEMS_FILE_PATH)
  @title_items = items[params[:id]]['title_items']
  @excel_items = items[params[:id]]['excel_items']
  @items_erb = items[params[:id]]['items_erb']
  erb :'items/show'
end

get '/items/:id/edit' do
  items = get_items(ITEMS_FILE_PATH)
  @excel_items = items[params[:id]]['excel_items']
  @items_erb = items[params[:id]]['items_erb']
  erb :'/items/edit'
end

patch '/items/:id' do
  title_items = params[:title_items]
  excel_items = params[:excel_items]
  items_erb = params[:items_erb]

  items = get_items(ITEMS_FILE_PATH)
  items[params[:id]] = { 'title_items' => title_items, 'excel_items' => excel_items, 'items_erb' => items_erb }
  set_items(ITEMS_FILE_PATH, items)

  post_items(excel_items, items_erb)

  redirect "/items/#{params[:id]}"
end


delete '/items/:id' do
  excel_items = params[:excel_items]

  items = get_items(ITEMS_FILE_PATH)
  items.delete(params[:id])
  set_items(ITEMS_FILE_PATH, items)

  delete_items(excel_items)

  redirect '/items'
end






# get '/template' do
get '/template' do
  @template = get_template(TEMPLATE_FILE_PATH)
  erb :'template/index'
end

get '/template/new' do
  erb :'template/new'
end

# get '/template/:id' do
post '/template' do
  title_template = params[:title_template]
  content = params[:content]

  template = get_template(TEMPLATE_FILE_PATH)
  id = (template.keys.map(&:to_i).max + 1).to_s
  template[id] = { 'title_template' => title_template, 'content' => content}
  set_template(TEMPLATE_FILE_PATH, template)

  post_template(title_template, content)

  redirect '/template'
end


get '/template/:id' do
  template = get_template(TEMPLATE_FILE_PATH)
  @title_template = template[params[:id]]['title_template']
  @content = template[params[:id]]['content']
  erb :'template/show'
end

get '/template/:id/edit' do
  template = get_template(TEMPLATE_FILE_PATH)
  @title_template = template[params[:id]]['title_template']
  @content = template[params[:id]]['content']
  erb :'/template/edit'
end

patch '/template/:id' do
  title_template = params[:title_template]
  content = params[:content]

  template = get_template(TEMPLATE_FILE_PATH)
  template[params[:id]] = { 'title_template' => title_template, 'content' => content }
  set_template(TEMPLATE_FILE_PATH, template)

  post_template(title_template, content)

  redirect "/template/#{params[:id]}"
end


delete '/template/:id' do
  template = get_template(TEMPLATE_FILE_PATH)
  @title_template = template[params[:id]]['title_template']
  template.delete(params[:id])
  set_template(TEMPLATE_FILE_PATH, template)

  delete_template(@title_template)

  redirect '/template'
end