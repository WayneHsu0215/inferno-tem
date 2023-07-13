require 'sinatra'
require 'json'

enable :sessions

$recent_post_request = nil

get '/status' do
  status 200
  body 'Webhook接收程式運行中'
end

post '/fhir/webhook' do
  request_data = JSON.parse(request.body.read)

  resource_type = request_data['resourceType']
  patient_id = request_data['id']
  patient_name = request_data['name'][0]['text']
  patient_gender = request_data['gender']
  patient_birth_date = request_data['birthDate']
  patient_active = request_data['active']
  patient_identifiers = request_data['identifier']
  patient_age = request_data['extension'][0]['valueInteger']

  identifier = patient_identifiers.find { |id| id['system'] == 'http://www.moi.gov.tw/' }
  identifier_value = identifier['value'] if identifier

  puts "資源類型: #{resource_type}"
  puts "患者ID: #{patient_id}"
  puts "患者姓名: #{patient_name}"
  puts "患者性別: #{patient_gender}"
  puts "患者出生日期: #{patient_birth_date}"
  puts "患者活動狀態: #{patient_active}"
  puts "患者識別符: #{patient_identifiers}"
  puts "患者年齡: #{patient_age}"
  puts "患者身分證: #{identifier_value}"

  $recent_post_request = {
    resource_type: resource_type,
    patient_id: patient_id,
    patient_name: patient_name,
    patient_gender: patient_gender,
    patient_birth_date: patient_birth_date,
    patient_active: patient_active,
    patient_identifiers: patient_identifiers,
    patient_age: patient_age,
    identifier_value: identifier_value
  }
  status 200
  body 'Webhook請求已接收'
end

get '/fhir/webhook' do
  if $recent_post_request
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    content_type 'application/json'
    status 200
    $recent_post_request.to_json
  else
    status 404
    body '找不到頁面'
  end
end

set :port, 4568

# require_relative 'lib/inferno_template/pat_create_json'

# def webhook_handler(request)
#   template = InfernoTemplate::PATCreateJSON.new

#   # 进行其他操作...

#   { status: 200, body: 'Success' }
# end
