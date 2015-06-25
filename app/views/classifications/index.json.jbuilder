json.array!(@classifications) do |classification|
  json.extract! classification, :id, :text
  json.url classification_url(classification, format: :json)
end
