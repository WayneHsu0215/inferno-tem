require 'inferno'
require_relative 'lib/inferno_template' 
# 模擬請求資料
data = {
  "resourceType": "Patient",
  "id": "PMR-Pat2",
  "name": [{"text": "趙錢孫"}],
  "gender": "male",
  "birthDate": "1997-01-01",
  "active": true,
  "identifier": [
    {
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "MR",
            "display": "Medical record number"
          }
        ]
      },
      "system": "https://www.ntuh.gov.tw/ntuh/ntuhgroup.jsp",
      "value": "123456"
    },
    {
      "system": "http://www.moi.gov.tw/",
      "value": "Z123456789"
    },
    {
      "system": "http://loinc.org",
      "value": "29762-2"
    }
  ],
  "extension": [
    {
      "url": "http://example.com/age",
      "valueInteger": 24
    }
  ]
}

# 建立測試套件
suite = InfernoTemplate::Suite.new do |suite|
  suite.input :url, title: 'FHIR 伺服器基本 URL', value: 'http://hapi.fhir.org/baseR4'
  suite.fhir_client.url(suite.input[:url])
end

# 建立測試工作階段
test_session = Inferno::TestSession.new
test_session.test_suite = suite
test_session.instance_variable_set(:@responses, patient: Inferno::Models::ResourceReference.new(resource: data))
test_session.instance_variable_set(:@webhook_data, data)

# 執行測試
test_session.run

# 輸出測試結果
puts "測試結果:"
puts "總共執行了 #{test_session.test_results.count} 個測試。"
puts "通過的測試數量: #{test_session.passes.count}"
puts "失敗的測試數量: #{test_session.failures.count}"
puts "跳過的測試數量: #{test_session.omits.count}"
