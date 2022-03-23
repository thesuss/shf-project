FactoryBot.define do

  klass = AdminOnly::FileDeliveryMethod
  method_names = klass::METHOD_NAMES

  factory :file_delivery_method, class: klass,
           aliases: [ :file_delivery_upload_now ] do
    name { method_names[:upload_now] }
    description_sv { 'Ladda upp nu' }
    description_en { 'Upload now' }
    default_option { true }
  end

  factory :file_delivery_upload_later, class: klass do
    name { method_names[:upload_later] }
    description_sv { 'Ladda upp senare' }
    description_en { 'Upload later' }
  end

  factory :file_delivery_email, class: klass do
    name { method_names[:email] }
    description_sv { 'Skicka via e-post' }
    description_en { 'Send via email' }
  end

  factory :file_delivery_mail, class: klass do
    name { method_names[:mail] }
    description_sv { 'Skicka via vanlig post' }
    description_en { 'Send via regular mail' }
  end

  factory :file_delivery_files_uploaded, class: klass do
    name { method_names[:files_uploaded] }
    description_sv { 'Alla filer är uppladdade' }
    description_en { 'All files are uploaded' }
  end
end
