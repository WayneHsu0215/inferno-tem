module InfernoTemplate
  class PATCreateJSON < Inferno::TestGroup
    title 'Patient Create JSON'
    description 'Patient Create JSON'
    id :pat_create_2022

    test do
      title 'Patient Create JSON for SC1'
      description '執行各項護理技術、檢查、治療、手術等醫療處置前對病人做身分確認'

      input :patient_id,
            title: 'Patient ID'

      # Named requests can be used by other tests
      makes_request :patient

      run do
        fhir_read(:patient, patient_id, name: :patient)

        assert_response_status(200)

        # (40) FHIR Server 能正確呈現回傳 id 及病人資料
        assert_resource_type(:patient)
        assert resource.id == patient_id,
               "Requested resource with id #{patient_id}, received resource with id #{resource.id}"

        # (70) Patient.identifier 所有 SC 需一致（身分證字號／病歷號擇一）
        identifier_systems = {
          # ntuhgroup 系統的URL和格式
          'https://www.ntuh.gov.tw/ntuh/ntuhgroup.jsp' => /^\d{6}$/,
          # 身分證號系統的URL和格式
          'http://www.moi.gov.tw/' => /^[A-Z]\d{9}$/
        }

        identifier = resource.identifier.find { |id| identifier_systems.keys.include?(id.system) }
        assert !identifier.nil?, "No requested identifier system found"

        system_regex = identifier_systems[identifier.system]
        assert identifier.value.match?(system_regex),
               "Received invalid identifier value #{identifier.value}"

        # (90) [必要欄位] Patient.active: true
        assert resource.active == true,
               "Request resource.active == true, received resource.active == #{resource.active}"

        # (100) Patient.gender 由 FHIR 給定的 code 隨機四選一
        valid_genders = ["male", "female", "other", "unknown"]
        assert valid_genders.include?(resource.gender),
               "Received invalid gender #{resource.gender}"

        # (110) Patient.birthDate 由 1970-01-01 到現在隨機選一天，需補 0
        assert resource.birthDate.match?(/^\d{4}-\d{2}-\d{2}$/),
               "Received invalid resource birthDate #{resource.birthDate}"

      end
    end
  end
end
